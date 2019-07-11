`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

	reg [`DATA_WIDTH-1:0] rf[`DATA_WIDTH - 1:0];
	assign rdata1=rf[raddr1];
	assign rdata2=rf[raddr2];
	always@(posedge clk)
	begin
	  	if(rst)
	  	begin
	  		rf[0]<=0;
			rf[1]<=0;
	  		rf[2]<=0;
			rf[3]<=0;
	  		rf[4]<=0;
			rf[5]<=0;
	  		rf[6]<=0;
			rf[7]<=0;
	  		rf[8]<=0;
			rf[9]<=0;
	  		rf[10]<=0;
			rf[11]<=0;
	  		rf[12]<=0;
			rf[13]<=0;
	  		rf[14]<=0;
			rf[15]<=0;
	  		rf[16]<=0;
			rf[17]<=0;
	  		rf[18]<=0;
			rf[19]<=0;
	  		rf[20]<=0;
			rf[21]<=0;
	  		rf[22]<=0;
			rf[23]<=0;
	  		rf[24]<=0;
			rf[25]<=0;
	  		rf[26]<=0;
			rf[27]<=0;
	  		rf[28]<=0;
			rf[29]<=0;
	  		rf[30]<=0;
			rf[31]<=0;															
		end
		else 
		begin
			if(wen==1&&waddr!=0)
			begin
				rf[waddr]<=wdata;
			end
		end
	end

endmodule
