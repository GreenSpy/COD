`timescale 10ns / 1ns

`define DATA_WIDTH 32

module alu(
    input [`DATA_WIDTH - 1:0] A,
    input [`DATA_WIDTH - 1:0] B,
    input [9:0] alu_op,
    output Zero,
    output [`DATA_WIDTH - 1:0] Result
);

// control code decomposition
wire alu_add ;   //加法操作
wire alu_sub ;   //减法操作
wire alu_slt ;   //有符号比较，小于置位
wire alu_sltu;   //无符号比较，小于置位
wire alu_and ;   //按位与
wire alu_or  ;   //按位或
wire alu_xor ;   //按位异或
wire alu_sll ;   //逻辑左移
wire alu_srl ;   //逻辑右移
wire alu_sra ;   //算术右移

assign alu_add  = alu_op[0];
assign alu_sub  = alu_op[1];
assign alu_slt  = alu_op[2];
assign alu_sltu = alu_op[3];
assign alu_and  = alu_op[4];
assign alu_or   = alu_op[5];
assign alu_xor  = alu_op[6];
assign alu_sll  = alu_op[7];
assign alu_srl  = alu_op[8];
assign alu_sra  = alu_op[9];

wire [31:0] add_sub_result; 
wire [31:0] slt_result; 
wire [31:0] sltu_result;
wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] xor_result;
wire [31:0] sll_result; 
wire [31:0] srl_result; 
wire [31:0] sra_result; 

// 32-bit adder
wire [31:0] adder_a     ;
wire [31:0] adder_b     ;
wire [33:0] adder_result;
wire        adder_cin   ;

assign adder_a      = A;
assign adder_b      = (alu_sub | alu_slt) ? ~B : B;
assign adder_cin    = (alu_sub | alu_slt);
assign adder_result = {adder_a,adder_cin} + {adder_b,adder_cin};

// ADD, SUB result
assign add_sub_result = adder_result[32:1];

// SLT result
assign slt_result[31:1] = 31'b0;
assign slt_result[0]    = (A[31]  & ~B[31])
                        | ((A[31] ~^ B[31]) & adder_result[32]);

// SLTU result
assign sltu_result[31:1] = 31'b0;
assign sltu_result[0]    = (A < B);                        

// bitwise operation
assign and_result = A & B;
assign or_result  = A | B;
assign xor_result = A ^ B;

// SLL result 
assign sll_result = A << B[4:0];

// SRL, SRA result
assign sra_result = {{31{A[31]}}, 1'b0} << ~(B[4:0]) | A >> B[4:0];
assign srl_result = A >> B[4:0];

// flag output
assign Zero     = ({Result} == 32'b0);

// final result mux
assign Result     = ({32{alu_add | alu_sub}} & add_sub_result)
                  | ({32{alu_slt          }} & slt_result    )
                  | ({32{alu_sltu         }} & sltu_result   )
                  | ({32{alu_and          }} & and_result    )
                  | ({32{alu_or           }} & or_result     )
                  | ({32{alu_xor          }} & xor_result    )
                  | ({32{alu_sll          }} & sll_result    )
                  | ({32{alu_sra          }} & sra_result    )
                  | ({32{alu_srl          }} & srl_result    );                                    

endmodule
