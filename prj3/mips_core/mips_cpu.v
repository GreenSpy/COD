`timescale 10ns / 1ns

`define IF    3'b000
`define IW    3'b001
`define ID_EX 3'b010
`define WB    3'b011
`define ST    3'b100
`define LD    3'b101
`define RDW   3'b110

`timescale 10ns / 1ns

module mips_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg [31:0] PC,
	output reg Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output reg Inst_Ack,

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
	output reg Read_data_Ack
);

//FSM logic
reg [2:0] current_state;
reg [2:0] next_state   ;

reg [31:0] IR ;
reg [31:0] MDR;

reg RegWrite_Valid;
reg MemRead_Valid ;
reg MemWrite_Valid;

//IF
wire [31:0] ALUResult;
wire        zero     ;

wire [31:0] PCset   ;
wire [31:0] PCadd4  ;
wire [31:0] PCadd8  ;
wire [31:0] PCoffset;
wire [31:0] PCjump  ;

wire [31:0] signextend_out;
wire [31:0] zeroextend_out;
wire [31:0] shiftleft2_out;

//ID
wire [4 :0] RegDst  ;
wire [5 :0] Branch  ;
wire [11:0] ALUOp   ;
wire [3 :0] ALUSrc  ;
wire [2 :0] RegSrc  ;
wire [11:0] MemSrc  ;
wire        JumpWB  ;
wire        RegWrite;
wire        MemRead_Ack ;
wire        MemWrite_Ack;

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
always @(posedge Inst_Valid) 
begin
    IR <= (current_state == `IW) ? Instruction : IR;
end

//MDR
always @(posedge Read_data_Valid) 
begin
    MDR <= (current_state == `RDW) ? Read_data : MDR;
end

//first-stage
always @ (posedge clk or negedge rst)
begin
    if (rst)
        current_state <= `IF;
    else
        current_state <= next_state;
end
	
//second-stage
always @ (*)
begin
    if (rst) next_state = `IF;
    else 
    begin
        case (current_state)
        `IF:
            next_state = Inst_Req_Ack ? `IW : `IF;
        `IW:
            next_state = Inst_Valid ? `ID_EX : `IW;
        `ID_EX:
            next_state =  Branch       ? `IF:
                          MemWrite_Ack ? `ST:
                          MemRead_Ack  ? `LD:
                                         `WB;
        `ST:
            next_state = Mem_Req_Ack ? `IF : `ST;
        `LD:
            next_state = Mem_Req_Ack ? `RDW: `LD;
        `WB:
            next_state = `IF;
        `RDW:
            next_state = Read_data_Valid ? `WB : `RDW;	
        default:
            next_state = `IF;
        endcase
    end
end

//third-stage
//Inst_Req_Valid
always @ (*)
begin
    if (rst)
    begin
        Inst_Req_Valid <= 0;
    end 
    else
    begin
        case (current_state)
        `IF:
        begin
            Inst_Req_Valid <= 1;
        end
        default:
        begin
            Inst_Req_Valid <= 0;
        end
        endcase 
    end
end

//Inst_Ack
always @ (*)
begin
    if (rst)
    begin
        Inst_Ack <= 1;
    end 
    else
    begin
        case (current_state)
        `IF:
        begin
            Inst_Ack <= 0;
        end
        `IW:
        begin;
            Inst_Ack <= 1;
        end
        `WB:
        begin
            Inst_Ack <= 0;
        end
        default:
        begin
            Inst_Ack <= rst;
        end
        endcase 
    end
end

//Read_data_Ack
always @ (*)
begin
    if (rst)
    begin
        Read_data_Ack <= 0;
    end 
    else
    begin
        case (current_state)
        `RDW:
        begin
            Read_data_Ack <= 1;
        end
        default:
        begin
            Read_data_Ack <= 0;
        end
        endcase 
    end
end

//MemRead_Valid
always @ (*)
begin
    if (rst)
    begin
        MemRead_Valid <= 0;
    end 
    else
    begin
        case (current_state)
        `LD:
        begin
            MemRead_Valid <= 1;
        end
        default:
        begin
            MemRead_Valid <= 0;
        end
        endcase 
    end
end

//MemWrite_Valid
always @ (*)
begin
    if (rst)
    begin
        MemWrite_Valid <= 0;
    end 
    else
    begin
        case (current_state)
        `ST:
        begin
            MemWrite_Valid <= 1;
        end
        default:
        begin
            MemWrite_Valid <= 0;
        end
        endcase 
    end
end

//RegWrite_Valid
always @ (*)
begin
    if (rst)
    begin
        RegWrite_Valid <= 0;
    end 
    else
    begin
        case (current_state)
        `WB:
        begin
            RegWrite_Valid <= 1;
        end
        `ID_EX:
        begin
            RegWrite_Valid <= JumpWB;
        end
        default:
        begin
            RegWrite_Valid <= 0;
        end
        endcase 
    end
end

// PC++
// IF取指
assign PCadd4   = PC+4;
assign PCadd8   = PC+8;
assign PCoffset = PCadd4 + shiftleft2_out;
assign PCjump   = {PC[31:28],IR[25:0],2'b00};
assign PCset    = (Branch[0] &~zero) ? PCoffset:
                  (Branch[1] & zero) ? PCoffset:
                   Branch[2] ? PCjump: 
                   Branch[3] ? RF_rdata1:
                  (Branch[4] &(~zero | (RF_rdata1==0))) ? PCoffset:
                  (Branch[5] &( zero & (RF_rdata1!=0))) ? PCoffset:
                   PCadd4  ;

always@(posedge clk)
begin
    if(rst)
        begin
            PC<=0;
        end
    else if(current_state == `ID_EX)
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
    IR[31:26],
    IR[20:16],
    IR[5 : 0], 
    RegDst,
    Branch,
    JumpWB,
    MemRead_Ack,
    MemtoReg,
    ALUOp,
    MemWrite_Ack,
    ALUSrc,
    RegWrite,
    RegSrc,
    MemSrc
);

assign RF_waddr  = RegDst[0] ? IR[20:16]:
                   RegDst[1] ? IR[15:11]:
                   RegDst[2] ? 31:
                   RegDst[3] & (RF_rdata2!=0) ? IR[15:11]:
                   RegDst[4] & (RF_rdata2==0) ? IR[15:11]:  
                   0;
assign RF_raddr1 = IR[25:21];
assign RF_raddr2 = IR[20:16];
assign RF_wen = RegWrite;

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
assign ALU_data1 = ALUSrc[0] ? RF_rdata1:
                   ALUSrc[1] ? IR[10:6]:
                   ALUSrc[2] ? RF_rdata1:
                   ALUSrc[3] ? RF_rdata1:
                   RF_rdata1;
assign ALU_data2 = ALUSrc[0] ? signextend_out:
                   ALUSrc[1] ? RF_rdata2:
                   ALUSrc[2] ? zeroextend_out:
                   ALUSrc[3] ? 32'b0:
                   RF_rdata2;

sign_extend SignExtend(
    IR[15:0],
    signextend_out
);

zero_extend ZeroExtend(
    IR[15:0],
    zeroextend_out
);

shift_left_2 ShiftLeft2(
    signextend_out,
    shiftleft2_out
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

assign Address    = MemWrite ? {ALUResult[31:2],2'b0}:ALUResult;
assign Write_data = MemWrite ? RegOutput:RF_rdata2;

// WB写回
assign RF_wdata = MemtoReg  ? MemOutput:
                  RegSrc[0] ? ALUResult:
                  RegSrc[1] ? PCadd8   :
                  RegSrc[2] ? RF_rdata1:
                  32'b0     ;

endmodule