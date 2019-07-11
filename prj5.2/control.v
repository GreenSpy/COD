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

//instruction[6:0]
`define LUI   7'b0110111
`define AUIPC 7'b0010111
`define J     7'b1101111//jal
`define J_2   7'b1100111//jalr
`define B     7'b1100011
`define L     7'b0000011
`define S     7'b0100011
`define I     7'b0010011
`define R     7'b0110011

//instruction[14:12]
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

//instruction[31:25]
`define F_1 7'b0000000
`define F_2 7'b0100000

module control(
    input clk,
    input rst,
    input  Inst_Req_Ack,
    input  [31:0]inst,
    input  Inst_Valid,
    input  Mem_Req_Ack,
    input  Read_data_Valid,
    //输出立即数扩展
    output [31:0]sext,
    output [31:0]sext_b,
    output [31:0]sext_u,        
    //输出译码控制信号
    output [9:0]alu_op,
    output [2:0]alu_src_a,
    output [2:0]alu_src_b,
    output [3:0]reg_src,
    output [1:0]branch,
    output      reg_write,   
    output [7:0]mem_src,
    //输出i/o信号
    output Inst_Req_Valid,  
    output Inst_Ack,
    output MemRead,
    output MemWrite, 
    output Read_data_Ack,
    //输出时序控制信号
    output data_read, 
    output pc_write,
    output ir_write,
    output pc_src
);

wire  [6:0]inst_6_0  ;
wire  [2:0]inst_14_12;
wire  [6:0]inst_31_25;

assign inst_6_0   = inst[6 : 0];
assign inst_14_12 = inst[14:12];
assign inst_31_25 = inst[31:25];


//一级译码
////////////////////////////////////////////////////////////
wire type_j;
wire type_r;
wire type_s;
wire type_b;
wire type_i;
wire type_u;
wire type_l;
wire type_ical ;

assign type_j = (inst_6_0==`J);
assign type_r = (inst_6_0==`R);
assign type_s = (inst_6_0==`S);
assign type_b = (inst_6_0==`B);
assign type_i =  type_l   | type_ical | inst_jalr;
assign type_u  =  inst_lui | inst_auipc;

assign type_ical = (inst_6_0==`I);
assign type_l    = (inst_6_0==`L);

//二级译码
////////////////////////////////////////////////////////////
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

assign inst_jal   = (type_j);

assign inst_jalr  = (inst_6_0==`J_2 & inst_14_12==`JALR );

assign inst_beq   = (type_b & inst_14_12==`BEQ  );
assign inst_bne   = (type_b & inst_14_12==`BNE  );
assign inst_blt   = (type_b & inst_14_12==`BLT  );
assign inst_bge   = (type_b & inst_14_12==`BGE  );
assign inst_bltu  = (type_b & inst_14_12==`BLTU );
assign inst_bgeu  = (type_b & inst_14_12==`BGEU );

assign inst_lb    = (type_l & inst_14_12==`LB   );
assign inst_lh    = (type_l & inst_14_12==`LH   );
assign inst_lw    = (type_l & inst_14_12==`LW   );
assign inst_lbu   = (type_l & inst_14_12==`LBU  );
assign inst_lhu   = (type_l & inst_14_12==`LHU  );

assign inst_sb    = (type_s & inst_14_12==`SB   );
assign inst_sh    = (type_s & inst_14_12==`SH   );
assign inst_sw    = (type_s & inst_14_12==`SW   );

assign inst_addi  = (type_ical & inst_14_12==`ADDI );
assign inst_slti  = (type_ical & inst_14_12==`SLTI );
assign inst_sltiu = (type_ical & inst_14_12==`SLTIU);
assign inst_xori  = (type_ical & inst_14_12==`XORI );
assign inst_ori   = (type_ical & inst_14_12==`ORI  );
assign inst_andi  = (type_ical & inst_14_12==`ANDI );
assign inst_slli  = (type_ical & inst_14_12==`SLLI & inst_31_25==`F_1);
assign inst_srli  = (type_ical & inst_14_12==`SRLI & inst_31_25==`F_1);
assign inst_srai  = (type_ical & inst_14_12==`SRAI & inst_31_25==`F_2);

assign inst_add   = (type_r & inst_14_12==`ADD  & inst_31_25==`F_1);
assign inst_sub   = (type_r & inst_14_12==`SUB  & inst_31_25==`F_2);
assign inst_sll   = (type_r & inst_14_12==`SLL  & inst_31_25==`F_1);
assign inst_slt   = (type_r & inst_14_12==`SLT  & inst_31_25==`F_1);
assign inst_sltu  = (type_r & inst_14_12==`SLTU & inst_31_25==`F_1);
assign inst_xor   = (type_r & inst_14_12==`XOR  & inst_31_25==`F_1);
assign inst_srl   = (type_r & inst_14_12==`SRL  & inst_31_25==`F_1);
assign inst_sra   = (type_r & inst_14_12==`SRA  & inst_31_25==`F_2);
assign inst_or    = (type_r & inst_14_12==`OR   & inst_31_25==`F_1);
assign inst_and   = (type_r & inst_14_12==`AND  & inst_31_25==`F_1);


//译码控制信号
///////////////////////////////////////////////////////////////
wire [9:0]alu_op_tmp     ;
wire [2:0]alu_src_a_tmp  ;
wire [2:0]alu_src_b_tmp  ;
wire [3:0]reg_src_tmp    ;
wire [1:0]branch_tmp     ;
wire      reg_write_tmp  ;    
wire [7:0]mem_src_tmp    ;

assign alu_op_tmp[0] = type_l     | type_s    | inst_jalr  |
                       inst_addi  | inst_add  | inst_jal   ;
assign alu_op_tmp[1] = inst_beq   | inst_bne  | inst_sub   ;
assign alu_op_tmp[2] = inst_blt   | inst_bge  | inst_slti  |
                       inst_slt   ;
assign alu_op_tmp[3] = inst_bltu  | inst_bgeu | inst_sltiu |
                       inst_sltu  ;
assign alu_op_tmp[4] = inst_andi  | inst_and  ;
assign alu_op_tmp[5] = inst_or    | inst_ori  ;
assign alu_op_tmp[6] = inst_xor   | inst_xori ;
assign alu_op_tmp[7] = inst_sll   | inst_slli ;
assign alu_op_tmp[8] = inst_srl   | inst_srli ;
assign alu_op_tmp[9] = inst_sra   | inst_srai ; 

assign alu_src_a_tmp = (inst_auipc | type_j) ? 2'b10: 2'b00;  //pc-4:Reg_A       
    
assign alu_src_b_tmp = (type_i | type_s | type_j | inst_auipc) ? 2'b01: 2'b00;//imm:

assign branch_tmp[0] = inst_beq   | inst_bge  | inst_bgeu ;
assign branch_tmp[1] = inst_bne   | inst_blt  | inst_bltu ;

assign mem_src_tmp[0] = inst_lw   ;
assign mem_src_tmp[1] = inst_lb   ;
assign mem_src_tmp[2] = inst_lbu  ;
assign mem_src_tmp[3] = inst_lh   ;
assign mem_src_tmp[4] = inst_lhu  ;
assign mem_src_tmp[5] = inst_sw   ;
assign mem_src_tmp[6] = inst_sb   ;
assign mem_src_tmp[7] = inst_sh   ;
    
assign reg_write_tmp  = type_u | type_r | type_j | type_ical | inst_jalr | type_l;

assign reg_src_tmp[0] = type_l   ;
assign reg_src_tmp[1] = inst_lui ;
assign reg_src_tmp[2] = inst_jalr| type_j;
assign reg_src_tmp[3] = 1'b0;

//立即数扩展输出
////////////////////////////////////////////////////////////
wire [31:0]imm_i;
wire [31:0]imm_s;
wire [31:0]imm_b;
wire [31:0]imm_u;
wire [31:0]imm_j;

assign imm_i  = {{21{inst[31]}}, inst[30:20]};
assign imm_s  = {{21{inst[31]}}, inst[30:25], inst[11:7]};
assign imm_b  = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
assign imm_u  = {inst[31:12], 12'b0};
assign imm_j  = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

assign sext = ({32{type_i}} & {imm_i})
            | ({32{type_s}} & {imm_s})
            | ({32{type_b}} & {imm_b})
            | ({32{type_u}} & {imm_u})
            | ({32{type_j}} & {imm_j});

assign sext_b = imm_b;
assign sext_u = imm_u;

//二段状态机
///////////////////////////////////////////////////////
reg [3:0]current_state;
wire [3:0]next_state;

wire [ 3:0] IF_next;
wire [ 3:0] IW_next;
wire [ 3:0] ID_next;
wire [ 3:0] EX_next;  
wire [ 3:0] LD_next;
wire [ 3:0] RW_next;
wire [ 3:0] ST_next;
wire [ 3:0] WB_next;

assign IF_next    = (Inst_Req_Ack) ? `IW: `IF; 
assign IW_next    = (Inst_Valid)   ? `ID: `IW;  
assign ID_next    = `EX;
assign EX_next    = (type_l) ? `LD:
                    (type_s) ? `ST:
                    (type_b) ? `IF:
                               `WB;                                             
assign LD_next    = (Mem_Req_Ack)     ? `RDW: `LD ;
assign RW_next    = (Read_data_Valid) ? `WB : `RDW;
assign ST_next    = (Mem_Req_Ack)     ? `IF : `ST ;
assign WB_next    = `IF;
        
assign next_state = (current_state == `IF)  ? IF_next :
                    (current_state == `IW)  ? IW_next :
                    (current_state == `ID)  ? ID_next :
                    (current_state == `EX)  ? EX_next :
                    (current_state == `LD)  ? LD_next :
                    (current_state == `RDW) ? RW_next :
                    (current_state == `ST)  ? ST_next :
                    (current_state == `WB)  ? WB_next :
                                            `IF;

always@(posedge clk) begin     
    current_state <= (rst) ? `RST : next_state;
end

//输出信号
///////////////////////////////////////////////////////////
assign Inst_Req_Valid = (current_state == `IF);    
assign Inst_Ack       = (current_state == `IW || current_state == `RST);  
assign MemRead        = (current_state == `LD);
assign MemWrite       = (current_state == `ST);      
assign Read_data_Ack  = (current_state == `RDW);


//实际控制信号
////////////////////////////////////////
assign alu_op    = (current_state == `IF || current_state == `ID) ? 10'b0000000001:  //ADD                      
                   alu_op_tmp   ;
assign alu_src_a = (current_state == `IF) ? 2'b01:
                   (current_state == `ID) ? 2'b10:  
                   alu_src_a_tmp; 
assign alu_src_b = (current_state == `IF) ? 2'b11:
                   (current_state == `ID) ? 2'b10:
                   alu_src_b_tmp;

assign reg_src   = (current_state == `WB) ? reg_src_tmp : 3'b0001;
assign branch    = (current_state == `IF || current_state == `IW || current_state == `ID || current_state == `RST) ? 2'b0 : branch_tmp ;
assign mem_src   = (current_state == `IF || current_state == `IW || current_state == `ID || current_state == `RST) ? 8'b0 : mem_src_tmp;
assign reg_write = (current_state == `WB) ? reg_write_tmp : 1'b0;


//时序控制信号
///////////////////////////////////////////
assign data_read = (current_state == `RDW && Read_data_Ack && Read_data_Valid);  
assign pc_write  = (current_state == `IF && Inst_Req_Ack  && Inst_Req_Valid || current_state == `EX && (type_j || inst_jalr));
assign ir_write  = (current_state == `IW && Inst_Valid && Inst_Ack);     
assign pc_src    = (current_state == `IF || current_state == `EX && (type_j || inst_jalr));

endmodule