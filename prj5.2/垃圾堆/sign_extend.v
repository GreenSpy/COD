`timescale 10 ns / 1 ns
	
	
module sign_extend(
    input [31:0]inst,
    input [4:0]imm,
    output [31:0]sign_extend_out
);
 
assign sign_extend_out = ({32{imm[0]}} & {inst[31:12],12'b0}                                   )
                       | ({32{imm[1]}} & {{12{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0})
                       | ({32{imm[2]}} & {{21{inst[31]}},inst[30:20]}                          )
                       | ({32{imm[3]}} & {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0}  )
                       | ({32{imm[4]}} & {{21{inst[31]}},inst[30:25],inst[11:7]}               );

endmodule
