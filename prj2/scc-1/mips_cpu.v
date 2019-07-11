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



///////////////////////////////////////////////

`define ADDIU 6'b001001

`define LW    6'b100011

`define SW    6'b101011

`define BNE   6'b000101

`define SLL   6'b000000

`define R 2'b10
`define SL 2'b00
`define Beq 2'b01



///////////////////////////////////////////////

// PC++

// IF取指

wire [31:0]ALUResult;
wire carryout;
wire overflow;
wire zero;



wire [31:0]PCset;
wire [31:0]PCadd4;
wire [31:0]PCoffset;

wire [31:0] signextend_out;
wire [31:0] shiftleft2_out;

assign PCadd4 = PC+4;
assign PCoffset = PCadd4 + shiftleft2_out;

assign PCset=(Instruction[28]?~zero:zero)?PCoffset:PCadd4;


pc Pc(rst,clk,PCset,PC);



///////////////////////////////////////////////

// Control

// ID译码



wire [2:0]RegDst;

wire [2:0]Branch;

wire [11:0]ALUOp;

wire ALUSrc;

wire RegWrite;



control Control(

		Instruction[31:26],

		RegDst,

	    Branch,

	    MemRead,

	    MemtoReg,

	    ALUOp,

	    MemWrite,

	    ALUSrc,

	    RegWrite,
        Write_strb

		);



wire [4 :0]RF_waddr ;

wire [4 :0]RF_raddr1;

wire [4 :0]RF_raddr2;

wire       RF_wen   ;

wire [31:0]RF_wdata ;

wire [31:0]RF_rdata1;

wire [31:0]RF_rdata2;


assign RF_waddr = ((RegDst==0)?Instruction[15:11]:Instruction[20:16]);

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









// ALU

// EX执行




sign_extend SignExtend(
	Instruction[15:0],
	signextend_out
);


shift_left_2 ShiftLeft2(
	signextend_out,
	shiftleft2_out
);



alu ALU(

	RF_rdata1,

	ALUSrc?signextend_out:RF_rdata2,

	ALUOp,
    overflow,
    carryout,
    zero,

	ALUResult

);





// data memory

// MEM访存



assign Address=ALUResult;
assign Write_data=RF_rdata2;



// output MemRead

// Extender

// WB写回



assign RF_wdata =(MemtoReg?Read_data:ALUResult);



endmodule

