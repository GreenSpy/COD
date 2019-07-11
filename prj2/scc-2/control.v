`timescale 10ns / 1ns

//op//////////////////////
`define R      6'b000000
`define SLL    6'b000000
`define ADDU   6'b100001
`define JR     6'b001000
`define OR     6'b100101
`define SLT    6'b101010
//////////////////////////
`define ADDIU  6'b001001
`define LW     6'b100011
`define SW     6'b101011
`define BNE    6'b000101
`define BEQ    6'b000100
`define J      6'b000010
`define JAL    6'b000011
`define LUI    6'b001111
`define SLTI   6'b001010
`define SLTIU  6'b001011

module control(
	input  [5:0]inst_31_26,
	input  [5:0]inst_5_0,
	output [2:0]reg_dst,
    output [3:0]branch,
    output mem_read,
    output mem_to_reg,
    output [11:0]alu_op,
    output mem_write,
    output [1:0]alu_src,
    output reg_write,
	output [3:0]write_strb
);


wire inst_addiu;
wire inst_bne  ;
wire inst_lw   ;
wire inst_sw   ;
wire inst_sll  ;
wire inst_addu ;
wire inst_beq  ;
wire inst_j    ;
wire inst_jal  ;
wire inst_jr   ;
wire inst_lui  ;
wire inst_or   ;
wire inst_slt  ;
wire inst_slti ;
wire inst_sltiu;

assign inst_addiu = (inst_31_26==`ADDIU);
assign inst_bne   = (inst_31_26==`BNE  );
assign inst_lw    = (inst_31_26==`LW   );
assign inst_sw    = (inst_31_26==`SW   );
assign inst_sll   = (inst_31_26==`R & inst_5_0==`SLL );
assign inst_addu  = (inst_31_26==`R & inst_5_0==`ADDU);
assign inst_beq   = (inst_31_26==`BEQ  );
assign inst_j     = (inst_31_26==`J    );
assign inst_jal   = (inst_31_26==`JAL  );
assign inst_jr    = (inst_31_26==`R & inst_5_0==`JR  );
assign inst_lui   = (inst_31_26==`LUI  );
assign inst_or    = (inst_31_26==`R & inst_5_0==`OR  );
assign inst_slt   = (inst_31_26==`R & inst_5_0==`SLT );
assign inst_slti  = (inst_31_26==`SLTI );
assign inst_sltiu = (inst_31_26==`SLTIU);


assign alu_op[ 0] = inst_addu | inst_addiu | inst_lw   |
                    inst_sw   | inst_jal   | inst_jr   ;
assign alu_op[ 1] = inst_bne  | inst_beq   ;
assign alu_op[ 2] = inst_slt  | inst_slti  ;
assign alu_op[ 3] = inst_sltiu;
assign alu_op[ 4] = 0;
assign alu_op[ 5] = 0;
assign alu_op[ 6] = inst_or   ;
assign alu_op[ 7] = 0;
assign alu_op[ 8] = inst_sll  ;
assign alu_op[ 9] = 0;
assign alu_op[10] = 0;
assign alu_op[11] = inst_lui;

assign reg_dst[0] = inst_addiu | inst_lw   | inst_lui  |
                    inst_slti  | inst_sltiu;
assign reg_dst[1] = inst_sll   | inst_addu | inst_or   |
                    inst_slt   ;
assign reg_dst[2] = inst_jal   ;
assign branch [0] = inst_bne;
assign branch [1] = inst_beq;
assign branch [2] = inst_j | inst_jal ;
assign branch [3] = inst_jr ;
assign mem_read   = inst_lw;
assign mem_to_reg = inst_lw;
assign mem_write  = inst_sw;
assign reg_write  = inst_addiu | inst_lw   | inst_sll  |
                    inst_sll   | inst_addu | inst_jal  |
                    inst_or    | inst_slt  |inst_slti  |
                    inst_sltiu | inst_lui  ;
assign alu_src[0] = inst_addiu | inst_lw   | inst_sw   |
                    inst_lui   | inst_slti | inst_sltiu;
assign alu_src[1] = inst_sll   ;
assign write_strb = inst_sw ? 4'b1111 : 4'b0000;

endmodule