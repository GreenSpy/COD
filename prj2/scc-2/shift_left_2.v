`timescale 10ns / 1ns

	
`define OUTPUT_WIDTH 32
	
module shift_left_2(
	input [31:0]shift_left_2_in,
	output [31:0]shift_left_2_out
);
	
	assign shift_left_2_out={shift_left_2_in[29:0],2'b00};
	
endmodule