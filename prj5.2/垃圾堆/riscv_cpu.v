`timescale 10ns / 1ns

`define IF    4'b0000
`define IW    4'b0001
`define ID    4'b0010
`define EX    4'b0011
`define WB    4'b0100
`define ST    4'b0101
`define LD    4'b0110
`define RDW   4'b0111
`define RST   4'b1000

`timescale 10ns / 1ns

module riscv_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg [31:0] PC,
	output Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output Inst_Ack,

	//Memory request channel
	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output Read_data_Ack
);


//FSM logic
reg  [3:0] current_state;
wire [3:0] next_state   ;

reg [31:0] IR ;
reg [31:0] MDR;

wire RegWrite_Valid;
wire MemRead_Valid ;
wire MemWrite_Valid;

//IF
wire [31:0] ALUResult;
wire        zero     ;

wire [31:0] PCset   ;
wire [31:0] PCadd4  ;
wire [31:0] PCoffset;
wire [31:0] PCjump  ;

wire [31:0] signextend_out;
wire [31:0] zeroextend_out;
wire [31:0] shiftleft2_out;

//ID
wire [1 :0] Branch   ;
wire [9 :0] ALUOp    ;
wire [3 :0] ALUSrc   ;
wire [4 :0] RegSrc   ;
wire [7 :0] MemSrc   ;
wire [1 :0] JumpWB   ;
wire [4 :0] Imm      ;
wire        Imm_5    ;

wire     MemRead_Ack ;
wire     MemWrite_Ack;

wire [4 :0] RF_waddr ;
wire [4 :0] RF_raddr1;
wire [4 :0] RF_raddr2;
wire        RF_wen   ;
wire [31:0] RF_wdata ;
wire [31:0] RF_rdata1;
wire [31:0] RF_rdata2;

//EX
wire [31:0] ALU_data1;
wire [31:0] ALU_data2;

//MEM
wire [31:0] MemOutput;
wire [31:0] RegOutput;

//FSM logic

//IR
always @(posedge clk) 
begin
    if(Inst_Valid & (current_state == `IW))
        IR <= Instruction;
    else
        IR <= IR;
end

//MDR
always @(posedge Read_data_Valid) 
begin
    MDR <= (current_state == `RDW) ? Read_data : MDR;
end

    wire [ 3:0] IF_next;
    wire [ 3:0] IW_next;
    wire [ 3:0] ID_next;
    wire [ 3:0] EX_next;  
    wire [ 3:0] LD_next;
    wire [ 3:0] RW_next;
    wire [ 3:0] ST_next;
    wire [ 3:0] WB_next;

    /* Finite State Machine */  
    assign IF_next    = (Inst_Req_Ack)      ? `IW: `IF; 
    assign IW_next    = (Inst_Valid)        ? `ID: `IW;  
    assign ID_next    = `EX;
    assign EX_next    = (MemRead)         ? `LD:
                        (MemWrite)         ? `ST:
                        (Branch)         ? `IF:
                                              `WB;                                             
    assign LD_next    = (Mem_Req_Ack)       ? `RDW: `LD;
    assign RW_next    = (Read_data_Valid)   ? `WB: `RDW;
    assign ST_next    = (Mem_Req_Ack)       ? `IF: `ST;
    assign WB_next    = `IF;
        
    assign next_state = (current_state == `IF) ? IF_next :
                        (current_state == `IW) ? IW_next :
                        (current_state == `ID) ? ID_next :
                        (current_state == `EX) ? EX_next :
                        (current_state == `LD) ? LD_next :
                        (current_state == `RDW) ? RW_next :
                        (current_state == `ST) ? ST_next :
                        (current_state == `WB) ? WB_next :
                                                 `IF;

    always@(posedge clk) begin     
        current_state <= (rst) ? `RST : next_state;
    end


    /* I/O Signals */
    assign Inst_Req_Valid = (current_state == `IF);    
    assign Inst_Ack       = (current_state == `IW || current_state == `RST);  
    assign MemRead_Valid  = (current_state == `LD);  //MemRead is set 0 in IF_state, due to the FPGA settings   
    assign MemWrite_Valid = (current_state == `ST);    
    assign RegWrite_Valid = (current_state == `WB);   
    assign Read_data_Ack  = (current_state == `RDW);

// PC++
// IF取指
assign PCadd4   = PC + 4;
assign PCoffset = PC + signextend_out;
assign PCjump   = {PC[31:28],IR[25:0],2'b00};
assign PCset    = (Branch[0] & zero) ? PCoffset:
                  (Branch[1] &~zero) ? PCoffset:
                   JumpWB[0] ? PCoffset:
                   JumpWB[1] ? {ALUResult[31:1],1'b0}:                    
                   PCadd4  ;

always@(posedge clk)
begin
    if(rst)
        begin
            PC<=0;
        end
    else if(current_state == `EX)
        begin
            PC<=PCset;
        end
    else
        begin
            PC<=PC;
        end
end

// ID译码
control Control(
    IR[6:0],
    IR[14:12],
    IR[31:25],
    Imm,
    ALUOp,
    ALUSrc, 
    RegSrc,
    Branch,
    JumpWB,
    MemWrite_Ack,    
    MemRead_Ack,
    MemSrc,
    Imm_5
);


assign RF_waddr  = IR[11: 7];
assign RF_raddr1 = IR[19:15];
assign RF_raddr2 = IR[24:20];
assign RF_wen    = Imm_5 ? (IR[25]==0) : (RegSrc!=0);

reg_file Reg_file(
    clk,
    rst,
    RF_waddr,
    RF_raddr1,
    RF_raddr2,
    RF_wen & RegWrite_Valid,
    RF_wdata,
    RF_rdata1,
    RF_rdata2
);

// EX执行
assign ALU_data1 = ALUSrc[0] ? PC :
                   RF_rdata1 ;
assign ALU_data2 = ALUSrc[0] ? signextend_out:
                   ALUSrc[1] ? signextend_out:
                   ALUSrc[2] ? RF_rdata2     :
                   ALUSrc[3] ? IR[25:20]     :                   
                   RF_rdata2 ;

sign_extend SignExtend(
    IR,
    Imm,
    signextend_out
);

alu ALU(
    ALU_data1,
    ALU_data2,
    ALUOp,
    zero,
    ALUResult
);

// MEM访存
mem_operation MemOperation(
    MemSrc,
    MDR,
    RF_rdata2,
    ALUResult[1:0],
    MemOutput,
    RegOutput,
    Write_strb
);

assign MemRead = MemRead_Ack & MemRead_Valid;

assign MemWrite = MemWrite_Ack & MemWrite_Valid;

assign Address    = ALUResult;
assign Write_data = RegOutput;

// WB写回
assign RF_wdata = RegSrc[0] ? signextend_out:
                  RegSrc[1] ? MemOutput:
                  RegSrc[2] ? ALUResult:
                  RegSrc[3] ? PC + 4 - signextend_out:
                  RegSrc[4] ? PC + 4 - signextend_out:                  
                  32'b0     ;

endmodule