	`timescale 10ns / 1ns

//Instruction[31:26]
`define R      6'b000000
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
`define ANDI   6'b001100
`define REGIMM 6'b000001
`define BLEZ   6'b000110
`define LB     6'b100000
`define LBU    6'b100100
`define LH     6'b100001
`define LHU    6'b100101
`define LWL    6'b100010
`define LWR    6'b100110
`define ORI    6'b001101
`define SB     6'b101000
`define SH     6'b101001
`define SWL    6'b101010
`define SWR    6'b101110
`define XORI   6'b001110

//Instruction[20:16]
`define BGEZ   5'b00001
`define BLTZ   5'b00000

//Instruction[5:0]
`define SLL    6'b000000
`define ADDU   6'b100001
`define JR     6'b001000
`define OR     6'b100101
`define SLT    6'b101010
`define AND    6'b100100
`define JALR   6'b001001
`define MOVN   6'b001011
`define MOVZ   6'b001010
`define NOR    6'b100111
`define SLLV   6'b000100
`define SLTU   6'b101011
`define SRA    6'b000011
`define SRAV   6'b000111
`define SRL    6'b000010
`define SRLV   6'b000110
`define SUBU   6'b100011
`define XOR    6'b100110
`define BGTZ   6'b000111

module control(
    input  [5:0]inst_31_26,
    input  [4:0]inst_20_16,
    input  [5:0]inst_5_0,
    output [4:0]reg_dst,
    output [5:0]branch,
    output jump_wb,
    output mem_read,
    output mem_to_reg,
    output [11:0]alu_op,
    output mem_write,
    output [3:0]alu_src,
    output reg_write,
    output [2:0]reg_src,
    output [11:0]mem_src
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
wire inst_and  ;
wire inst_andi ;
wire inst_bgez ;
wire inst_blez ;
wire inst_bltz ;
wire inst_jalr ;
wire inst_lb   ;
wire inst_lbu  ;
wire inst_lh   ;
wire inst_lhu  ;
wire inst_lwl  ;
wire inst_lwr  ;
wire inst_movn ;
wire inst_movz ;
wire inst_nor  ;
wire inst_ori  ;
wire inst_sb   ;
wire inst_sh   ;
wire inst_sllv ;
wire inst_sltu ;
wire inst_sra  ;
wire inst_srav ;
wire inst_srl  ;
wire inst_srlv ;
wire inst_subu ;
wire inst_swl  ;
wire inst_swr  ;
wire inst_xor  ;
wire inst_xori ;
wire inst_bgtz ;


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
assign inst_and   = (inst_31_26==`R & inst_5_0==`AND );
assign inst_andi  = (inst_31_26==`ANDI );
assign inst_bgez  = (inst_31_26==`REGIMM & inst_20_16==`BGEZ );
assign inst_blez  = (inst_31_26==`BLEZ );
assign inst_bltz  = (inst_31_26==`REGIMM & inst_20_16==`BLTZ );
assign inst_jalr  = (inst_31_26==`R & inst_5_0==`JALR);
assign inst_lb    = (inst_31_26==`LB   );
assign inst_lbu   = (inst_31_26==`LBU  );
assign inst_lh    = (inst_31_26==`LH   );
assign inst_lhu   = (inst_31_26==`LHU  );
assign inst_lwl   = (inst_31_26==`LWL  );
assign inst_lwr   = (inst_31_26==`LWR  );
assign inst_movn  = (inst_31_26==`R & inst_5_0==`MOVN);
assign inst_movz  = (inst_31_26==`R & inst_5_0==`MOVZ);
assign inst_nor   = (inst_31_26==`R & inst_5_0==`NOR );
assign inst_ori   = (inst_31_26==`ORI  );
assign inst_sb    = (inst_31_26==`SB   );
assign inst_sh    = (inst_31_26==`SH   );
assign inst_sllv  = (inst_31_26==`R & inst_5_0==`SLLV);
assign inst_sltu  = (inst_31_26==`R & inst_5_0==`SLTU);
assign inst_sra   = (inst_31_26==`R & inst_5_0==`SRA );
assign inst_srav  = (inst_31_26==`R & inst_5_0==`SRAV);
assign inst_srl   = (inst_31_26==`R & inst_5_0==`SRL );
assign inst_srlv  = (inst_31_26==`R & inst_5_0==`SRLV);
assign inst_subu  = (inst_31_26==`R & inst_5_0==`SUBU);
assign inst_swl   = (inst_31_26==`SWL  );
assign inst_swr   = (inst_31_26==`SWR  );
assign inst_xor   = (inst_31_26==`R & inst_5_0==`XOR );
assign inst_xori  = (inst_31_26==`XORI);
assign inst_bgtz  = (inst_31_26==`BGTZ & inst_20_16==`BLTZ );

assign alu_op[ 0] = inst_addu | inst_addiu | inst_lw   |
                    inst_sw   | inst_jal   | inst_jr   |
                    inst_jalr | inst_lb    | inst_lbu  |
                    inst_lh   | inst_lhu   | inst_lwl  |
                    inst_lwr  | inst_sb    | inst_sh   |
                    inst_swl  | inst_swr   ;
assign alu_op[ 1] = inst_bne  | inst_beq   | inst_subu ;
assign alu_op[ 2] = inst_slt  | inst_slti  | inst_bgez |
                    inst_blez | inst_bltz  | inst_bgtz ;
assign alu_op[ 3] = inst_sltiu| inst_sltu  ;
assign alu_op[ 4] = inst_and  | inst_andi  ;
assign alu_op[ 5] = inst_nor  ;
assign alu_op[ 6] = inst_or   | inst_ori   ;
assign alu_op[ 7] = inst_xor  | inst_xori  ;
assign alu_op[ 8] = inst_sll  | inst_sllv  ;
assign alu_op[ 9] = inst_srl  | inst_srlv  ;
assign alu_op[10] = inst_sra  | inst_srav  ;
assign alu_op[11] = inst_lui;

assign reg_dst[0] = inst_addiu | inst_lw   | inst_lui  |
                    inst_slti  | inst_sltiu| inst_lb   |
                    inst_lbu   | inst_lh   | inst_lhu  |
                    inst_lwl   | inst_lwr  | inst_ori  |
                    inst_xori  | inst_andi ;
assign reg_dst[1] = inst_sll   | inst_addu | inst_or   |
                    inst_slt   | inst_and  | inst_xor  |
                    inst_jalr  | inst_nor  | inst_sllv |
                    inst_sltu  | inst_sra  | inst_srav |
                    inst_srl   | inst_srlv | inst_subu ;
assign reg_dst[2] = inst_jal   ;
assign reg_dst[3] = inst_movn  ;
assign reg_dst[4] = inst_movz  ;

assign branch [0] = inst_bne   | inst_bltz ;
assign branch [1] = inst_beq   | inst_bgez ;
assign branch [2] = inst_j     | inst_jal  ;
assign branch [3] = inst_jr    | inst_jalr ;
assign branch [4] = inst_blez  ;
assign branch [5] = inst_bgtz  ;

assign jump_wb    = inst_jal   | inst_jalr ;

assign mem_read   = inst_lw    | inst_lb   | inst_lbu  |
                    inst_lh    | inst_lhu  | inst_lwl  |
                    inst_lwr   ;

assign mem_src[ 0] = inst_lw    ;
assign mem_src[ 1] = inst_lb    ;
assign mem_src[ 2] = inst_lbu   ;
assign mem_src[ 3] = inst_lh    ;
assign mem_src[ 4] = inst_lhu   ;
assign mem_src[ 5] = inst_lwl   ;
assign mem_src[ 6] = inst_lwr   ;
assign mem_src[ 7] = inst_sw    ;
assign mem_src[ 8] = inst_sb    ;
assign mem_src[ 9] = inst_sh    ;
assign mem_src[10] = inst_swl   ;
assign mem_src[11] = inst_swr   ;

assign mem_to_reg = inst_lw    | inst_lb   | inst_lbu  |
                    inst_lh    | inst_lhu  | inst_lwl  |
                    inst_lwr   ;

assign mem_write  = inst_sw    | inst_sb   | inst_sh   |
                    inst_swl   | inst_swr  ;

assign reg_write  = inst_addiu | inst_lw   | inst_sll  |
                    inst_sll   | inst_addu | inst_jal  |
                    inst_or    | inst_slt  | inst_slti |
                    inst_sltiu | inst_lui  | inst_and  |
                    inst_andi  | inst_jalr | inst_lb   |
                    inst_lbu   | inst_lbu  | inst_lh   |
                    inst_lhu   | inst_lwl  | inst_lwr  |
                    inst_movn  | inst_movz | inst_nor  |
                    inst_ori   | inst_sllv | inst_sltu |
                    inst_sra   | inst_srav | inst_srl  |
                    inst_srlv  | inst_subu | inst_xor  |
                    inst_xori  ;

assign alu_src[0] = inst_addiu | inst_lw   | inst_sw   |
                    inst_lui   | inst_slti | inst_sltiu|
                    inst_lb    | inst_lbu  | inst_lh   |
                    inst_lhu   | inst_lwl  | inst_lwr  |
                    inst_sb    | inst_sh   |inst_swl   |
                    inst_swr   ;
assign alu_src[1] = inst_sll   | inst_sra  | inst_srl  ;
assign alu_src[2] = inst_andi  | inst_xori | inst_ori  ;
assign alu_src[3] = inst_bgez  | inst_blez | inst_bltz |
                    inst_bgtz  ;

assign reg_src[0] = inst_addiu | inst_sll  | inst_addu |
                    inst_lui   | inst_or   | inst_slt  |
                    inst_slti  | inst_sltiu| inst_and  |
                    inst_andi  | inst_nor  | inst_ori  |
                    inst_sllv  | inst_sltu | inst_sra  |
                    inst_srav  | inst_srl  | inst_srlv |
                    inst_subu  | inst_xor  | inst_xori ;
assign reg_src[1] = inst_jal   | inst_jalr ;
assign reg_src[2] = inst_movn  | inst_movz ; 

endmodule