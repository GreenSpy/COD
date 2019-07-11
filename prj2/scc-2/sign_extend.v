`timescale 10 ns / 1 ns
	
	
module sign_extend(
	input [15:0]sign_extend_in,
	output [31:0]sign_extend_out
);

assign sign_extend_out=(sign_extend_in[15]?{16'b1111_1111_1111_1111,sign_extend_in}:{16'b0000_0000_0000_0000,sign_extend_in});


endmodule