`timescale 10ns / 1ns

`define DATA_WIDTH 32

module alu_test
();
 	reg clk;
	reg [`DATA_WIDTH - 1:0] A;
	reg [`DATA_WIDTH - 1:0] B;
	reg [2:0] ALUop;
	wire Overflow;
	wire CarryOut;
	wire Zero;
	wire [`DATA_WIDTH - 1:0] Result;



 	initial begin
	A = 0;
	B = 0;
	ALUop = 0;
	clk = 0;
 	#1000000
 	$finish;
 	end

 	always@(posedge clk)
 	begin
 	A     <= {$random};
 	B     <= {$random};
 	ALUop <= {$random};
 	end

 	always begin
 	#5 
 	clk = ~clk;
 	end

	alu u_alu(
		.A(A),
		.B(B),
		.ALUop(ALUop),
		.Overflow(Overflow),
		.CarryOut(CarryOut),
		.Zero(Zero),
		.Result(Result)
	);

endmodule