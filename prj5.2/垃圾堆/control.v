`timescale 10ns / 1ns

//Instruction[6:0]
`define LUI   7'b0110111
`define AUIPC 7'b0010111
`define JAL   7'b1101111
`define J     7'b1100111//jalr
`define B     7'b1100011
`define L     7'b0000011
`define S     7'b0100011
`define I     7'b0010011
`define R     7'b0110011

//Instruction[14:12]
`define JALR  3'b000

`define BEQ   3'b000
`define BNE   3'b001
`define BLT   3'b100
`define BGE   3'b101
`define BLTU  3'b110
`define BGEU  3'b111

`define LB    3'b000
`define LH    3'b001
`define LW    3'b010
`define LBU   3'b100
`define LHU   3'b101

`define SB    3'b000
`define SH    3'b001
`define SW    3'b010

`define ADDI  3'b000
`define SLTI  3'b010
`define SLTIU 3'b011
`define XORI  3'b100
`define ORI   3'b110
`define ANDI  3'b111
`define SLLI  3'b001
`define SRLI  3'b101
`define SRAI  3'b101

`define ADD   3'b000
`define SUB   3'b000
`define SLL   3'b001
`define SLT   3'b010
`define SLTU  3'b011
`define XOR   3'b100
`define SRL   3'b101
`define SRA   3'b101
`define OR    3'b110
`define AND   3'b111

//Instruction[31:25]
`define F_1 7'b0000000
`define F_2 7'b0100000

module control(
    input  [6:0]inst_6_0,
    input  [2:0]inst_14_12,
    input  [6:0]inst_31_25,
    output [4:0]imm,
    output [9:0]alu_op,
    output [3:0]alu_src,
    output [4:0]reg_src,
    output [1:0]branch,
    output [1:0]jump_wb,
    output mem_write,    
    output mem_read,
    output [7:0]mem_src,
    output imm_5
);


wire inst_lui  ;
wire inst_auipc;
wire inst_jal  ;
wire inst_jalr ;
wire inst_beq  ;
wire inst_bne  ;
wire inst_blt  ;
wire inst_bge  ;
wire inst_bltu ;
wire inst_bgeu ;
wire inst_lb   ;
wire inst_lh   ;
wire inst_lw   ;
wire inst_lbu  ;
wire inst_lhu  ;
wire inst_sb   ;
wire inst_sh   ;
wire inst_sw   ;
wire inst_addi ;
wire inst_slti ;
wire inst_sltiu;
wire inst_xori ;
wire inst_ori  ;
wire inst_andi ;
wire inst_slli ;
wire inst_srli ;
wire inst_srai ;
wire inst_add  ;
wire inst_sub  ;
wire inst_sll  ;
wire inst_slt  ;
wire inst_sltu ;
wire inst_xor  ;
wire inst_srl  ;
wire inst_sra  ;
wire inst_or   ;
wire inst_and  ;


assign inst_lui   = (inst_6_0==`LUI  );
assign inst_auipc = (inst_6_0==`AUIPC);
assign inst_jal   = (inst_6_0==`JAL  );

assign inst_jalr  = (inst_6_0==`J & inst_14_12==`JALR );

assign inst_beq   = (inst_6_0==`B & inst_14_12==`BEQ  );
assign inst_bne   = (inst_6_0==`B & inst_14_12==`BNE  );
assign inst_blt   = (inst_6_0==`B & inst_14_12==`BLT  );
assign inst_bge   = (inst_6_0==`B & inst_14_12==`BGE  );
assign inst_bltu  = (inst_6_0==`B & inst_14_12==`BLTU );
assign inst_bgeu  = (inst_6_0==`B & inst_14_12==`BGEU );

assign inst_lb    = (inst_6_0==`L & inst_14_12==`LB   );
assign inst_lh    = (inst_6_0==`L & inst_14_12==`LH   );
assign inst_lw    = (inst_6_0==`L & inst_14_12==`LW   );
assign inst_lbu   = (inst_6_0==`L & inst_14_12==`LBU  );
assign inst_lhu   = (inst_6_0==`L & inst_14_12==`LHU  );

assign inst_sb    = (inst_6_0==`S & inst_14_12==`SB   );
assign inst_sh    = (inst_6_0==`S & inst_14_12==`SH   );
assign inst_sw    = (inst_6_0==`S & inst_14_12==`SW   );

assign inst_addi  = (inst_6_0==`I & inst_14_12==`ADDI );
assign inst_slti  = (inst_6_0==`I & inst_14_12==`SLTI );
assign inst_sltiu = (inst_6_0==`I & inst_14_12==`SLTIU);
assign inst_xori  = (inst_6_0==`I & inst_14_12==`XORI );
assign inst_ori   = (inst_6_0==`I & inst_14_12==`ORI  );
assign inst_andi  = (inst_6_0==`I & inst_14_12==`ANDI );

assign inst_slli  = (inst_6_0==`I & inst_14_12==`SLLI & inst_31_25==`F_1);
assign inst_srli  = (inst_6_0==`I & inst_14_12==`SRLI & inst_31_25==`F_1);
assign inst_srai  = (inst_6_0==`I & inst_14_12==`SRAI & inst_31_25==`F_2);

assign inst_add   = (inst_6_0==`R & inst_14_12==`ADD  & inst_31_25==`F_1);
assign inst_sub   = (inst_6_0==`R & inst_14_12==`SUB  & inst_31_25==`F_2);
assign inst_sll   = (inst_6_0==`R & inst_14_12==`SLL  & inst_31_25==`F_1);
assign inst_slt   = (inst_6_0==`R & inst_14_12==`SLT  & inst_31_25==`F_1);
assign inst_sltu  = (inst_6_0==`R & inst_14_12==`SLTU & inst_31_25==`F_1);
assign inst_xor   = (inst_6_0==`R & inst_14_12==`XOR  & inst_31_25==`F_1);
assign inst_srl   = (inst_6_0==`R & inst_14_12==`SRL  & inst_31_25==`F_1);
assign inst_sra   = (inst_6_0==`R & inst_14_12==`SRA  & inst_31_25==`F_2);
assign inst_or    = (inst_6_0==`R & inst_14_12==`OR   & inst_31_25==`F_1);
assign inst_and   = (inst_6_0==`R & inst_14_12==`AND  & inst_31_25==`F_1);


assign imm[0]     = inst_lui   | inst_auipc;
assign imm[1]     = inst_jal   ;
assign imm[2]     = inst_jalr  | inst_lb   | inst_lh    |
                    inst_lw    | inst_lbu  | inst_lhu   |
                    inst_addi  | inst_slti | inst_sltiu |
                    inst_xori  | inst_ori  | inst_andi  ;
assign imm[3]     = inst_beq   | inst_bne  | inst_blt   |
                    inst_bge   | inst_bltu | inst_bgeu  ;
assign imm[4]     = inst_sb    | inst_sh   | inst_sw    ;


assign alu_op[0]  = inst_auipc | inst_jalr | inst_lb    |
                    inst_lh    | inst_lw   | inst_lbu   |
                    inst_lhu   | inst_sb   | inst_lh    |
                    inst_sw    | inst_addi | inst_add   ;
assign alu_op[1]  = inst_beq   | inst_bne  | inst_sub   ;
assign alu_op[2]  = inst_blt   | inst_bge  | inst_slti  |
                    inst_slt   ;
assign alu_op[3]  = inst_bltu  | inst_bgeu | inst_sltiu |
                    inst_sltu  ;
assign alu_op[4]  = inst_andi  | inst_and   ;
assign alu_op[5]  = inst_or    | inst_ori   ;
assign alu_op[6]  = inst_xor   | inst_xori  ;
assign alu_op[7]  = inst_sll   | inst_slli  ;
assign alu_op[8]  = inst_srl   | inst_srli  ;
assign alu_op[9]  = inst_sra   | inst_srai  ;

assign alu_src[0] = inst_auipc ;
assign alu_src[1] = inst_jalr  | inst_lb    | inst_lh   |
                    inst_lw    | inst_lbu   | inst_lhu  |
                    inst_sb    | inst_sh    | inst_sw   |
                    inst_addi  | inst_slti  | inst_sltiu|
                    inst_xori  | inst_ori   | inst_andi ;
assign alu_src[2] = inst_beq   | inst_bne   | inst_blt  |
                    inst_bge   | inst_bltu  | inst_bgeu |
                    inst_add   | inst_sub   | inst_slt  |
                    inst_sltu  | inst_xor   | inst_or   |
                    inst_and   | inst_sll   | inst_srl  |
                    inst_sra   ;
assign alu_src[3] = inst_slli  | inst_srli  | inst_srai ;


assign reg_src[0] = inst_lui   ;
assign reg_src[1] = inst_lb    | inst_lh    | inst_lw   |
                    inst_lbu   | inst_lhu   ;
assign reg_src[2] = inst_auipc | inst_addi  | inst_slti |
                    inst_sltiu | inst_xori  | inst_ori  |
                    inst_andi  | inst_slli  | inst_srli |
                    inst_srai  | inst_add   | inst_sub  |
                    inst_sll   | inst_srli  | inst_srai |
                    inst_add   | inst_sub   | inst_sll  |
                    inst_slt   | inst_sltu  | inst_xor  |
                    inst_srl   | inst_sra   | inst_or   |
                    inst_and   ;
assign reg_src[3] = inst_jal   ;
assign reg_src[4] = inst_jalr  ;                    


assign branch [0] = inst_beq   | inst_bge   | inst_bgeu ;
assign branch [1] = inst_bne   | inst_blt   | inst_bltu ;


assign jump_wb[0] = inst_jal   ;
assign jump_wb[1] = inst_jalr  ;


assign mem_write  = inst_sb    | inst_sh    | inst_sw   ;


assign mem_read   = inst_lb    | inst_lh    | inst_lw   |
                    inst_lbu   | inst_lhu   ;

assign mem_src[0] = inst_lw    ;
assign mem_src[1] = inst_lb    ;
assign mem_src[2] = inst_lbu   ;
assign mem_src[3] = inst_lh    ;
assign mem_src[4] = inst_lhu   ;
assign mem_src[5] = inst_sw    ;
assign mem_src[6] = inst_sb    ;
assign mem_src[7] = inst_sh    ;

assign imm_5      = inst_slli  | inst_srli  | inst_srai  ;


endmodule