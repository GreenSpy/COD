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
module mips_cpu(
	input  rst,
	input  clk,
	output reg[31:0] PC,
	input  [31:0] Instruction,
	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	input  [31:0] Read_data,
	output MemRead
);
// pre-IF stage
wire [31:0] PCset         ;
wire to_fs_valid          ;
wire [31:0] branch_target ;
// IF stage
wire        fs_allowin         ;
wire        fs_ready_go        ;
reg         fs_valid           ;
wire        fs_to_ds_valid     ;
// ID stage
wire        ds_allowin    ;
wire        ds_ready_go   ;
wire        ds_to_es_valid;
reg         ds_valid      ;
reg  [31:0] ds_pc         ;
reg  [31:0] ds_inst       ;
wire [5:0]inst_31_26;
wire [4:0]inst_20_16;
wire [5:0]inst_5_0  ;
wire [4:0]reg_dst   ;
wire [4:0]branch    ;
wire mem_read       ;
wire mem_to_reg     ;
wire [11:0]alu_op   ;
wire mem_write      ;
wire [3:0]alu_src   ;
wire reg_write      ;
wire [2:0]reg_src   ;
wire [11:0]mem_src  ;
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
wire [4 :0] RF_waddr ;
wire [4 :0] RF_raddr1;
wire [4 :0] RF_raddr2;
wire        RF_wen   ;
wire [31:0] RF_wdata ;
wire [31:0] RF_rdata1;
wire [31:0] RF_rdata2;
// EX stage
wire       es_allowin    ;
wire       es_ready_go   ;
wire       es_to_ms_valid;
reg        es_valid      ;
reg  [31:0]es_pc         ;
reg  [31:0]es_inst       ;
reg  [31:0]es_RF_rdata1   ; 
reg  [31:0]es_RF_rdata2   ; 
reg  [4:0]es_reg_dst   ;
reg  es_mem_read       ;
reg  es_mem_to_reg     ;
reg  [11:0]es_alu_op   ;
reg  es_mem_write      ;
reg  [3:0]es_alu_src   ;
reg  es_reg_write      ;
reg  [2:0]es_reg_src   ;
reg  [11:0]es_mem_src  ;
wire [31:0] PCoffset;
wire [31:0] PCjump  ;
wire [ 1:0]es_ea;
wire [31:0]alu_data1 ;
wire [31:0]alu_data2 ;
wire [31:0]alu_result;
wire       zero      ;
wire [31:0]sign_extend_out ;
wire [31:0]zero_extend_out ;
wire [31:0]shift_left_2_out;
// MEM stage
wire        ms_allowin;
wire        ms_ready_go;
wire        ms_to_ws_valid;
reg         ms_valid;
reg  [31:0] ms_pc;
reg  [31:0] ms_inst;
reg  [ 1:0] ms_ea;
reg        ms_mem_to_reg;
reg        ms_reg_write ;
reg        ms_mem_write ;
reg        ms_mem_read  ;
reg  [31:0]ms_RF_rdata1 ;
reg  [31:0]ms_RF_rdata2 ;
reg  [31:0]ms_alu_result;
reg  [ 4:0]ms_reg_dst   ;
reg  [ 2:0]ms_reg_src   ;
reg  [11:0]ms_mem_src   ;
wire [31:0]ms_sdata;
wire [31:0]ms_ldata;
wire [3:0]sw_strb ;
wire [3:0]sb_strb ;
wire [3:0]sh_strb ;
wire [3:0]swl_strb;
wire [3:0]swr_strb;
wire [31:0]sw_result ;
wire [31:0]sb_result ;
wire [31:0]sh_result ;
wire [31:0]swl_result;
wire [31:0]swr_result;
wire [31:0]lw_result ;
wire [31:0]lb_result ;
wire [31:0]lbu_result;
wire [31:0]lh_result ;
wire [31:0]lhu_result;
wire [31:0]lwl_result;
wire [31:0]lwr_result;
// WB stage
wire       ws_allowin    ;
wire       ws_ready_go   ;
wire       ws_to_fs_valid;
reg        ws_valid      ;
reg  [31:0]ws_pc         ;
reg  [31:0]ws_inst       ;
reg        ws_mem_to_reg;
reg        ws_reg_write ;
reg  [31:0]ws_ldata     ;
reg  [31:0]ws_RF_rdata1 ;
reg  [31:0]ws_RF_rdata2 ;
reg  [31:0]ws_alu_result;
reg  [ 4:0]ws_reg_dst   ;
reg  [ 2:0]ws_reg_src   ;
// pre-IF stage

assign to_fs_valid  = ~rst;

// IF stage
assign fs_ready_go    = 1'b1;
assign fs_allowin     = !fs_valid || fs_ready_go && ds_allowin;
assign fs_to_ds_valid = fs_valid && fs_ready_go;
always @(posedge clk) begin
    if (rst) begin
        fs_valid <= 1'b1;
    end
    else if (fs_allowin) begin
        fs_valid <= to_fs_valid;  
    end
    if (rst) begin
        PC    <= 32'b0;
    end
    else if ((to_fs_valid) && fs_allowin) begin
        PC    <= ws_pc;
    end
end
// ID stage
assign ds_ready_go    = 1'b1;
assign ds_allowin     = !ds_valid || ds_ready_go && ms_allowin;
assign ds_to_es_valid = ds_valid && ds_ready_go;
always @(posedge clk) begin
    if (rst) begin
        ds_valid <= 1'b1;
    end
    else if (ds_allowin) begin
        ds_valid <= fs_to_ds_valid;
    end
    if (fs_to_ds_valid && ds_allowin) begin
        ds_inst <= Instruction;
        ds_pc   <= PC;
    end    
end
assign inst_31_26 = ds_inst[31:26];
assign inst_20_16 = ds_inst[21:16];
assign inst_5_0   = ds_inst[ 5: 0];
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
assign alu_op[ 0] = inst_addu | inst_addiu | inst_lw   |
                    inst_sw   | inst_jal   | inst_jr   |
                    inst_jalr | inst_lb    | inst_lbu  |
                    inst_lh   | inst_lhu   | inst_lwl  |
                    inst_lwr  | inst_sb    | inst_sh   |
                    inst_swl  | inst_swr   ;
assign alu_op[ 1] = inst_bne  | inst_beq   | inst_subu ;
assign alu_op[ 2] = inst_slt  | inst_slti  | inst_bgez |
                    inst_blez | inst_bltz  ;
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
assign branch [0] = inst_bne   | inst_bltz ;
assign branch [1] = inst_beq   | inst_bgez ;
assign branch [2] = inst_j     | inst_jal  ;
assign branch [3] = inst_jr    | inst_jalr ;
assign branch [4] = inst_blez  ;
assign mem_to_reg = inst_lw    | inst_lb   | inst_lbu  |
                    inst_lh    | inst_lhu  | inst_lwl  |
                    inst_lwr   ;
assign mem_write  = inst_sw    | inst_sb   | inst_sh   |
                    inst_swl   | inst_swr  ;
assign reg_write  = inst_addiu | inst_lw   | inst_xori |
                    inst_sll   | inst_addu | inst_jal  |
                    inst_or    | inst_slt  | inst_slti |
                    inst_sltiu | inst_lui  | inst_and  |
                    inst_andi  | inst_jalr | inst_lb   |
                    inst_lbu   | inst_lbu  | inst_lh   |
                    inst_lhu   | inst_lwl  | inst_lwr  |
                    inst_movn  | inst_movz | inst_nor  |
                    inst_ori   | inst_sllv | inst_sltu |
                    inst_sra   | inst_srav | inst_srl  |
                    inst_srlv  | inst_subu | inst_xor  ;
assign alu_src[0] = inst_addiu | inst_lw   | inst_sw   |
                    inst_lui   | inst_slti | inst_sltiu|
                    inst_lb    | inst_lbu  | inst_lh   |
                    inst_lhu   | inst_lwl  | inst_lwr  |
                    inst_sb    | inst_sh   |inst_swl   |
                    inst_swr   ;
assign alu_src[1] = inst_sll   | inst_sra  | inst_srl  ;
assign alu_src[2] = inst_andi  | inst_xori | inst_ori  ;
assign alu_src[3] = inst_bgez  | inst_blez | inst_bltz ;
assign reg_src[0] = inst_addiu | inst_sll  | inst_addu |
                    inst_lui   | inst_or   | inst_slt  |
                    inst_slti  | inst_sltiu| inst_and  |
                    inst_andi  | inst_nor  | inst_ori  |
                    inst_sllv  | inst_sltu | inst_sra  |
                    inst_srav  | inst_srl  | inst_srlv |
                    inst_subu  | inst_xor  | inst_xori ;
assign reg_src[1] = inst_jal   | inst_jalr ;
assign reg_src[2] = inst_movn  | inst_movz ; 
assign RF_raddr1 = ds_inst[25:21];
assign RF_raddr2 = ds_inst[20:16];
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
assign sign_extend_out=(ds_inst[15]?{16'b1111_1111_1111_1111,ds_inst[15:0]}:{16'b0000_0000_0000_0000,ds_inst[15:0]});
assign zero_extend_out={16'b0000_0000_0000_0000,ds_inst[15:0]};
assign shift_left_2_out={sign_extend_out[29:0],2'b00};
assign PCoffset = ds_pc + 4 + shift_left_2_out;
assign PCjump   = {ds_pc[31:28],ds_inst[25:0],2'b00};
assign PCset = branch ? branch_target : ds_pc + 4;
assign branch_target = (branch[0] & (RF_rdata1!=RF_rdata2)) ? PCoffset:
                       (branch[1] & (RF_rdata1==RF_rdata2)) ? PCoffset:
                        branch[2] ?  PCjump: 
                        branch[3] ?  RF_rdata1:
                       (branch[4] &((RF_rdata1<0) | (RF_rdata1==0))) ? PCoffset:
                        PCoffset;
// EX stage
assign es_ready_go    = 1'b1;
assign es_allowin     = !es_valid || es_ready_go && ms_allowin;
assign es_to_ms_valid = es_valid && es_ready_go;
always @(posedge clk) begin
    if (rst) begin
        es_valid <= 1'b1;
    end
    if (es_allowin) begin
        es_valid <= ds_to_es_valid;
    end
    if (ds_to_es_valid && es_allowin) begin
        es_pc           <= PCset;
        es_inst         <= ds_inst;        
        es_RF_rdata1    <= RF_rdata1;
        es_RF_rdata2    <= RF_rdata2;
        es_reg_dst      <= reg_dst;
        es_mem_read     <= mem_read;
        es_mem_to_reg   <= mem_to_reg;        
        es_alu_op       <= alu_op;
        es_mem_write    <= mem_write;
        es_alu_src      <= alu_src;
        es_reg_write    <= reg_write;
        es_reg_src      <= reg_src;
        es_mem_src      <= mem_src;
    end
end
assign es_ea = alu_result[1:0];
alu ALU(
    alu_data1,
    alu_data2,
    es_alu_op,
    zero,
    alu_result
);
assign alu_data1 = es_alu_src[0] ? es_RF_rdata1:
                   es_alu_src[1] ? es_inst[10:6]:
                   es_alu_src[2] ? es_RF_rdata1:
                   es_alu_src[3] ? es_RF_rdata1:
                   es_RF_rdata1;
assign alu_data2 = es_alu_src[0] ? sign_extend_out:
                   es_alu_src[1] ? es_RF_rdata2:
                   es_alu_src[2] ? zero_extend_out:
                   es_alu_src[3] ? 32'b0:
                   es_RF_rdata2;
// MEM stage
assign ms_ready_go    = 1'b1;
assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
assign ms_to_ws_valid = ms_valid && ms_ready_go;
always @(posedge clk) begin
    if (rst) begin
        ms_valid <= 1'b1;
    end
    else if (ms_allowin) begin
        ms_valid <= es_to_ms_valid;
    end
    if (es_to_ms_valid && ms_allowin) begin
        ms_pc           <= es_pc;
        ms_inst         <= es_inst;        
        ms_alu_result   <= alu_result;       
        ms_RF_rdata1    <= es_RF_rdata1;
        ms_RF_rdata2    <= es_RF_rdata2;
        ms_mem_to_reg   <= es_mem_to_reg;
        ms_reg_write    <= es_reg_write;
        ms_reg_dst      <= es_reg_dst;
        ms_reg_src      <= es_reg_src;
        ms_mem_read     <= es_mem_read;
        ms_mem_write    <= es_mem_write;
        ms_ea           <= es_ea;
        ms_mem_src      <= es_mem_src;
    end
end
assign lw_result  = Read_data;
assign lb_result  = ({32{ms_ea==2'b00}} & {{24{Read_data[ 7]}},Read_data[7 : 0]})
                  | ({32{ms_ea==2'b01}} & {{24{Read_data[15]}},Read_data[15: 8]})
                  | ({32{ms_ea==2'b10}} & {{24{Read_data[23]}},Read_data[23:16]})
                  | ({32{ms_ea==2'b11}} & {{24{Read_data[31]}},Read_data[31:24]});
assign lbu_result = ({32{ms_ea==2'b00}} & {{24'd0},Read_data[7 : 0]})
                  | ({32{ms_ea==2'b01}} & {{24'd0},Read_data[15: 8]})
                  | ({32{ms_ea==2'b10}} & {{24'd0},Read_data[23:16]})
                  | ({32{ms_ea==2'b11}} & {{24'd0},Read_data[31:24]});
assign lh_result  = ({32{ms_ea[1]==1'b0}} & {{16{Read_data[15]}},Read_data[15: 0]})               
                  | ({32{ms_ea[1]==1'b1}} & {{16{Read_data[31]}},Read_data[31:16]});
assign lhu_result = ({32{ms_ea[1]==1'b0}} & {{16'd0},Read_data[15: 0]})
                  | ({32{ms_ea[1]==1'b1}} & {{16'd0},Read_data[31:16]});
assign lwl_result = ({32{ms_ea==2'b00}} & {Read_data[ 7: 0],es_RF_rdata2[23:0]})
                  | ({32{ms_ea==2'b01}} & {Read_data[15: 0],es_RF_rdata2[15:0]})
                  | ({32{ms_ea==2'b10}} & {Read_data[23: 0],es_RF_rdata2[7 :0]})
                  | ({32{ms_ea==2'b11}} &  Read_data                        );
assign lwr_result = ({32{ms_ea==2'b00}} &  Read_data                         )
                  | ({32{ms_ea==2'b01}} & {es_RF_rdata2[31:24],Read_data[31: 8]})
                  | ({32{ms_ea==2'b10}} & {es_RF_rdata2[31:16],Read_data[31:16]})
                  | ({32{ms_ea==2'b11}} & {es_RF_rdata2[31: 8],Read_data[31:24]});
assign ms_ldata   = ({32{ms_mem_src[0]}} & lw_result )
                  | ({32{ms_mem_src[1]}} & lb_result )
                  | ({32{ms_mem_src[2]}} & lbu_result)
                  | ({32{ms_mem_src[3]}} & lh_result )
                  | ({32{ms_mem_src[4]}} & lhu_result)
                  | ({32{ms_mem_src[5]}} & lwl_result)
                  | ({32{ms_mem_src[6]}} & lwr_result); 
assign sw_strb  = 4'b1111;
assign sb_strb  = ({4{ms_ea==2'b00}} & 4'b0001)
                | ({4{ms_ea==2'b01}} & 4'b0010)
                | ({4{ms_ea==2'b10}} & 4'b0100)
                | ({4{ms_ea==2'b11}} & 4'b1000);
assign sh_strb  = ({4{ms_ea[1]==1'b0}} & 4'b0011)
                | ({4{ms_ea[1]==1'b1}} & 4'b1100);
assign swl_strb = ({4{ms_ea==2'b00}} & 4'b0001)
                | ({4{ms_ea==2'b01}} & 4'b0011)
                | ({4{ms_ea==2'b10}} & 4'b0111)
                | ({4{ms_ea==2'b11}} & 4'b1111);
assign swr_strb = ({4{ms_ea==2'b00}} & 4'b1111)
                | ({4{ms_ea==2'b01}} & 4'b1110)
                | ({4{ms_ea==2'b10}} & 4'b1100)
                | ({4{ms_ea==2'b11}} & 4'b1000);
assign Write_strb = ({4{ms_mem_src[ 7]}} & sw_strb )
                  | ({4{ms_mem_src[ 8]}} & sb_strb )
                  | ({4{ms_mem_src[ 9]}} & sh_strb )
                  | ({4{ms_mem_src[10]}} & swl_strb)
                  | ({4{ms_mem_src[11]}} & swr_strb);
assign sw_result  = ms_RF_rdata2;
assign sb_result  = ({32{ms_ea[1:0]==2'b00}} & {24'd0,ms_RF_rdata2[ 7: 0]      })
                  | ({32{ms_ea[1:0]==2'b01}} & {16'd0,ms_RF_rdata2[ 7: 0], 8'd0})
                  | ({32{ms_ea[1:0]==2'b10}} & { 8'd0,ms_RF_rdata2[ 7: 0],16'd0})
                  | ({32{ms_ea[1:0]==2'b11}} & {      ms_RF_rdata2[ 7: 0],24'd0});
assign sh_result  = ({32{ms_ea[1]==1'b0 }} & {16'd0,ms_RF_rdata2[15: 0]})
                  | ({32{ms_ea[1]==1'b1 }} & {ms_RF_rdata2[15: 0],16'd0});
assign swl_result = ({32{ms_ea[1:0]==2'b00}} & {24'd0,ms_RF_rdata2[31:24]}) 
                  | ({32{ms_ea[1:0]==2'b01}} & {16'd0,ms_RF_rdata2[31:16]}) 
                  | ({32{ms_ea[1:0]==2'b10}} & { 8'd0,ms_RF_rdata2[31: 8]}) 
                  | ({32{ms_ea[1:0]==2'b11}} & {      ms_RF_rdata2[31: 0]});
assign swr_result = ({32{ms_ea[1:0]==2'b00}} & {ms_RF_rdata2[31: 0]      }) 
                  | ({32{ms_ea[1:0]==2'b01}} & {ms_RF_rdata2[23: 0], 8'd0}) 
                  | ({32{ms_ea[1:0]==2'b10}} & {ms_RF_rdata2[15: 0],16'd0})
                  | ({32{ms_ea[1:0]==2'b11}} & {ms_RF_rdata2[ 7: 0],24'd0});
assign ms_sdata   = ({32{ms_mem_src[ 7]}} & sw_result )
                  | ({32{ms_mem_src[ 8]}} & sb_result )
                  | ({32{ms_mem_src[ 9]}} & sh_result )
                  | ({32{ms_mem_src[10]}} & swl_result)
                  | ({32{ms_mem_src[11]}} & swr_result);
assign MemWrite = ms_mem_write;
assign MemRead = ms_mem_read;
assign Address    = ms_mem_write ? {ms_alu_result[31:2],2'b0}:ms_alu_result;
assign Write_data = ms_mem_write ? ms_sdata:ms_RF_rdata2;
// WB stage 
assign ws_ready_go = 1'b1;
assign ws_allowin  = !ws_valid || ws_ready_go;
always @(posedge clk) begin
    if (rst) begin
        ws_valid <= 1'b1;
    end
    else if (ws_allowin) begin
        ws_valid <= ms_to_ws_valid;
    end
    if (ms_to_ws_valid && ws_allowin) begin
        ws_pc           <= ms_pc;
        ws_inst         <= ms_inst;
        ws_mem_to_reg   <= ms_mem_to_reg;
        ws_reg_write    <= ms_reg_write;
        ws_ldata        <= ms_ldata;
        ws_RF_rdata1    <= ms_RF_rdata1;
        ws_RF_rdata2    <= ms_RF_rdata2;
        ws_reg_dst      <= ms_reg_dst;
        ws_reg_src      <= ms_reg_src;
        ws_alu_result   <= ms_alu_result;
    end
end

assign RF_wen   = ws_reg_write && ws_valid;
assign RF_wdata = ws_mem_to_reg ? ws_ldata:
                  ws_reg_src[0] ? ws_alu_result:
                  ws_reg_src[1] ? ws_pc+8   :
                  ws_reg_src[2] ? ws_RF_rdata1 :
                  32'b0     ;
assign RF_waddr = ws_reg_dst[0] ? ws_inst[20:16]:
                  ws_reg_dst[1] ? ws_inst[15:11]:
                  ws_reg_dst[2] ? 31:
                  ws_reg_dst[3] & (ws_RF_rdata2!=0) ? ws_inst[15:11]:
                  ws_reg_dst[4] & (ws_RF_rdata2==0) ? ws_inst[15:11]:  
                  0;
endmodule