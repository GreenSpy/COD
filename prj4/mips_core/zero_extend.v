`timescale 10 ns / 1 ns
	
	
module zero_extend(
	input  [15:0]zero_extend_in,
	output [31:0]zero_extend_out
);

assign zero_extend_out={16'b0000_0000_0000_0000,zero_extend_in};


endmodule
