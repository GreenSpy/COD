`define DATA_WIDTH 32
`define AND 3'b000
`define OR  3'b001
`define ADD 3'b010
`define SUB 3'b110
`define SLT 3'b111

module alu(
    input [`DATA_WIDTH - 1:0] A,
    input [`DATA_WIDTH - 1:0] B,
    input [2:0] ALUop,
    output Overflow,
    output CarryOut,
    output Zero,
    output [`DATA_WIDTH - 1:0] Result
);

// control code decomposition
wire alu_and ;
wire alu_or  ;
wire alu_add ;
wire alu_sub ;
wire alu_slt ;
wire alu_null;

assign alu_and  = ( ALUop == 3'b000 ) ? 1'b1 : 1'b0;
assign alu_or   = ( ALUop == 3'b001 ) ? 1'b1 : 1'b0;
assign alu_add  = ( ALUop == 3'b010 ) ? 1'b1 : 1'b0;
assign alu_null = ((ALUop == 3'b011 ) &&
                  ( ALUop == 3'b100 ) &&
                  ( ALUop == 3'b101)) ? 1'b1 : 1'b0;   
assign alu_sub  = ( ALUop == 3'b110 ) ? 1'b1 : 1'b0;
assign alu_slt  = ( ALUop == 3'b111 ) ? 1'b1 : 1'b0;

wire [31:0] and_result    ;
wire [31:0] or_result     ;
wire [31:0] add_sub_result;
wire [31:0] slt_result    ;
wire [31:0] null_result   ;

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

// bitwise operation
assign and_result = A & B;
assign or_result  = A | B;

// undefined instructions result
assign null_result = 32'b0;

// flag output
assign Overflow = ((alu_add & (A[31] ~^ B[31])) | (alu_sub & (A[31]  ^ B[31]))) & (adder_result[32] ^ A[31]); 
assign CarryOut = (alu_add & adder_result[33])  | (alu_sub & ~adder_result[33]);
assign Zero     = ({Result} == 32'b0);

// final result mux
assign Result = ({32{alu_add | alu_sub}} & add_sub_result)
              | ({32{alu_and          }} & and_result    )
              | ({32{alu_or           }} & or_result     )
              | ({32{alu_slt          }} & slt_result    )
              | ({32{alu_null         }} & null_result   );

endmodule