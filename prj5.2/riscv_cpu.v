`timescale 10ns / 1ns

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
reg [31:0] IR ;
reg [31:0] MDR;
reg [31:0] PC_reg;
reg [31:0] ALU_reg;
reg [31:0] RF_reg1;
reg [31:0] RF_reg2;

wire RegWrite_Valid;
wire MemRead_Valid ;
wire MemWrite_Valid;

//IF
wire [31:0] ALUResult;
wire        zero     ;

wire [31:0] PCset   ;
wire [31:0] PCadd4  ;
wire [31:0] PCoffset;

wire [31:0] signextend_out;
wire [31:0] zeroextend_out;
wire [31:0] shiftleft2_out;

//ID
wire [31:0]sext;
wire [31:0]sext_b;
wire [31:0]sext_u;
wire [9:0]ALUOp;
wire [2:0]ALUSrcA;
wire [2:0]ALUSrcB;
wire [3:0]RegSrc;
wire [1:0]Branch;
wire      Reg_Write;   
wire [7:0]MemSrc;
wire      DataRead; 
wire      PCWrite;
wire      IRWrite;
wire      PCSrc;

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

//reg logic
//pre-IF
wire IR_wen;
assign IR_wen = ~DataRead & IRWrite;
//IR
always @(posedge clk) 
begin
    IR <= IR_wen ? Instruction : IR;
end
//MDR
always @(posedge clk) 
begin
    MDR <= DataRead ? Read_data : MDR;
end
//ALU_reg
always @(posedge clk) 
begin
    ALU_reg <= ALUResult;
end
//RF_reg1
always @(posedge clk) 
begin
    RF_reg1 <= RF_rdata1;
end
//RF_reg2
always @(posedge clk) 
begin
    RF_reg2 <= RF_rdata2;
end
//PC_reg
always @(posedge clk) 
begin
    if(rst)
        PC_reg <= PC_reg;
    else
        PC_reg <= PC;
end

// PC++
// IF取指
always@(posedge clk) 
begin
    if(rst)
         PC <= 32'd0;
    else                  
        PC <= (PCWrite | BranchPerf) ? PCset : PC;           
end

assign BranchPerf = (Branch[0] & zero) | (Branch[1] &~zero);
assign PCset = PCSrc ? ALUResult : ALU_reg; 

// ID译码
control Control(
    clk,
    rst,
    Inst_Req_Ack,
    IR,
    Inst_Valid,
    Mem_Req_Ack,
    Read_data_Valid,
    sext,
    sext_b,
    sext_u,    
    ALUOp,
    ALUSrcA,
    ALUSrcB,
    RegSrc,
    Branch,
    RegWrite,   
    MemSrc,
    Inst_Req_Valid,  
    Inst_Ack,
    MemRead,
    MemWrite, 
    Read_data_Ack,
    DataRead, 
    PCWrite,
    IRWrite,
    PCSrc
);

assign RF_waddr  = IR[11: 7];
assign RF_raddr1 = IR[19:15];
assign RF_raddr2 = IR[24:20];
assign RF_wen    = RegWrite ;

reg_file Reg_file(
    clk,
    rst,
    RF_waddr,
    RF_raddr1,
    RF_raddr2,
    RF_wen,
    RF_wdata,
    RF_rdata1,
    RF_rdata2
);

// EX执行
assign ALU_data1  = (ALUSrcA == 2'b01) ? PC      :
                    (ALUSrcA == 2'b10) ? PC-4    :
                                         RF_reg1 ; 
assign ALU_data2  = (ALUSrcB == 2'b01) ? sext     : 
                    (ALUSrcB == 2'b10) ? sext_b   :
                    (ALUSrcB == 2'b11) ? 32'd4    :
                                         RF_reg2;

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
    RF_reg2,
    ALU_reg[1:0],
    MemOutput,
    RegOutput,
    Write_strb
);

assign Address    = {ALU_reg[31:2], 2'b00};
assign Write_data = RegOutput;

// WB写回
assign RF_wdata = RegSrc[0] ? MemOutput:
                  RegSrc[1] ? sext_u:
                  RegSrc[2] ? PC_reg:
                  RegSrc[3] ? ALU_reg:                 
                              ALU_reg;

endmodule