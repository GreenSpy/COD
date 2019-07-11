`timescale 10ns / 1ns

`define ADDIU 6'b001001
`define LW    6'b100011
`define SW    6'b101011
`define BNE   6'b000101
`define SLL   6'b000000

`define nop 3'b000
`define bne 3'b001

`define R 2'b10
`define SL 2'b00
`define Beq 2'b01


module control(
	input [5:0]instruction,
	output [2:0]reg_dst,
    output [2:0]branch,
    output mem_read,
    output mem_to_reg,
    output [11:0]alu_op,
    output mem_write,
    output alu_src,
    output reg_write,
	output [3:0]write_strb
);


wire [5 :0] inst_31_26; //op
//wire [4 :0] inst_25_21; //rs
//wire [4 :0] inst_20_16; //rt
//wire [4 :0] inst_15_11; //rd
//wire [4 :0] inst_10_6 ; //sa
//wire [5 :0] inst_5_0  ; //func
//wire [16:0] inst_15_0 ; //imm
//wire [26:0] inst_25_0 ; //jidx

assign inst_31_26 = instruction[5:0];
//assign inst_25_21 = instruction[25:21];
//assign inst_20_16 = instruction[20:16];
//assign inst_15_11 = instruction[15:11];
//assign inst_10_6  = instruction[10: 6];
//assign inst_5_0   = instruction[ 5: 0];
//assign inst_15_0  = instruction[15: 0];
//assign inst_25_0  = instruction[25: 0];

wire inst_addiu;
wire inst_bne  ;
wire inst_lw   ;
wire inst_sw   ;
wire inst_sll  ;

assign inst_addiu = (inst_31_26==`ADDIU );
assign inst_bne   = (inst_31_26==`BNE   );
assign inst_lw    = (inst_31_26==`LW    );
assign inst_sw    = (inst_31_26==`SW    );
assign inst_sll   = (inst_31_26==`SLL   );

assign alu_op[ 0] = inst_addiu | inst_lw | inst_sw;
assign alu_op[ 1] = inst_bne  ;
assign alu_op[ 2] = 0;
assign alu_op[ 3] = 0;
assign alu_op[ 4] = 0;
assign alu_op[ 5] = 0;
assign alu_op[ 6] = 0;
assign alu_op[ 7] = 0;
assign alu_op[ 8] = inst_sll  ;
assign alu_op[ 9] = 0;
assign alu_op[10] = 0;
assign alu_op[11] = 0;

assign reg_dst     = inst_addiu | inst_lw;
assign branch     = inst_bne ? `bne:`nop;
assign mem_read   = inst_lw;
assign mem_to_reg = inst_lw;
assign mem_write  = inst_sw;
assign reg_write  = inst_addiu | inst_lw | inst_sll;
assign alu_src    = inst_addiu | inst_lw | inst_sw | inst_sll;
assign write_strb = 4'b1111;
                  
endmodule