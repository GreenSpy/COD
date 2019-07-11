`timescale 10ns / 1ns

module mips_cpu(
	input  rst,
	input  clk,
	output [31:0] PC,
	input  [31:0] Instruction,
	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	input  [31:0] Read_data,
	output MemRead
);

// PC++
// IF取指

wire [31:0] ALUResult;
wire zero;

wire [31:0] PCset         ;
wire [31:0] PCadd4        ;
wire [31:0] PCadd8        ;
wire [31:0] PCoffset      ;
wire [31:0] PCjump        ;
wire [31:0] signextend_out;
wire [31:0] zeroextend_out;
wire [31:0] shiftleft2_out;

assign PCadd4   = PC+4;
assign PCadd8   = PC+8;
assign PCoffset = PCadd4 + shiftleft2_out;
assign PCjump   = {PC[31:28],Instruction[25:0],2'b00};
assign PCset    = (Branch[0] &~zero) ? PCoffset:
                  (Branch[1] & zero) ? PCoffset:
				   Branch[2] ? PCjump: 
                   Branch[3] ? RF_rdata1:
                  (Branch[4] &(~zero | (RF_rdata1==0))) ? PCoffset:
                   PCadd4  ;

pc Pc(rst,clk,PCset,PC);

// ID译码

wire [4 :0] RegDst  ;
wire [4 :0] Branch  ;
wire [11:0] ALUOp   ;
wire [3 :0] ALUSrc  ;
wire [2 :0] RegSrc  ;
wire [11:0] MemSrc  ;
wire        RegWrite;

control Control(
		Instruction[31:26],
		Instruction[20:16],
		Instruction[5 : 0], 
        RegDst,
	    Branch,
	    MemRead,
	    MemtoReg,
	    ALUOp,
	    MemWrite,
	    ALUSrc,
	    RegWrite,
        RegSrc,
		MemSrc
		);

wire [4 :0] RF_waddr ;
wire [4 :0] RF_raddr1;
wire [4 :0] RF_raddr2;
wire        RF_wen   ;
wire [31:0] RF_wdata ;
wire [31:0] RF_rdata1;
wire [31:0] RF_rdata2;


assign RF_waddr  = RegDst[0] ? Instruction[20:16]:
                   RegDst[1] ? Instruction[15:11]:
				   RegDst[2] ? 31:
                   RegDst[3] & (RF_rdata2!=0) ? Instruction[15:11]:
				   RegDst[4] & (RF_rdata2==0) ? Instruction[15:11]:  
                   0;
assign RF_raddr1 = Instruction[25:21];
assign RF_raddr2 = Instruction[20:16];
assign RF_wen = RegWrite;

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

wire [31:0] ALU_data1;
wire [31:0] ALU_data2;

assign ALU_data1 = ALUSrc[0] ? RF_rdata1:
                   ALUSrc[1] ? Instruction[10:6]:
                   ALUSrc[2] ? RF_rdata1:
                   ALUSrc[3] ? RF_rdata1:
                   RF_rdata1;
assign ALU_data2 = ALUSrc[0] ? signextend_out:
                   ALUSrc[1] ? RF_rdata2:
                   ALUSrc[2] ? zeroextend_out:
                   ALUSrc[3] ? 32'b0:
                   RF_rdata2;

sign_extend SignExtend(
	Instruction[15:0],
	signextend_out
);

zero_extend ZeroExtend(
	Instruction[15:0],
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

wire [31:0] MemOutput;
wire [31:0] RegOutput;

mem_operation MemOperation(
    MemSrc,
    Read_data,
    RF_rdata2,
    ALUResult[1:0],
    MemOutput,
    RegOutput,
    Write_strb
);

assign Address    = MemWrite ? {ALUResult[31:2],2'b0}:ALUResult;
assign Write_data = MemWrite ? RegOutput:RF_rdata2;

// WB写回

assign RF_wdata = MemtoReg  ? MemOutput:
                  RegSrc[0] ? ALUResult:
				  RegSrc[1] ? PCadd8   :
				  RegSrc[2] ? RF_rdata1:
				  32'b0     ;

endmodule

