`timescale 10ns / 1ns

module mem_operation(
    input  [7 :0]control_code,
    input  [31:0]mem_input,
    input  [31:0]reg_input,
    input  [1 :0]ea,    
    output [31:0]mem_output,
    output [31:0]reg_output,
    output [3 :0]write_strb
);

wire [31:0] lw_result ;
wire [31:0] lb_result ;
wire [31:0] lbu_result;
wire [31:0] lh_result ;
wire [31:0] lhu_result;


assign lw_result  = mem_input;
    

assign lb_result  = ({32{ea==2'b00}} & {{24{mem_input[ 7]}},mem_input[7 : 0]})
                  | ({32{ea==2'b01}} & {{24{mem_input[15]}},mem_input[15: 8]})
                  | ({32{ea==2'b10}} & {{24{mem_input[23]}},mem_input[23:16]})
                  | ({32{ea==2'b11}} & {{24{mem_input[31]}},mem_input[31:24]});

assign lbu_result = ({32{ea==2'b00}} & {{24'd0},mem_input[7 : 0]})
                  | ({32{ea==2'b01}} & {{24'd0},mem_input[15: 8]})
                  | ({32{ea==2'b10}} & {{24'd0},mem_input[23:16]})
                  | ({32{ea==2'b11}} & {{24'd0},mem_input[31:24]});

assign lh_result  = ({32{ea[1]==1'b0}} & {{16{mem_input[15]}},mem_input[15: 0]})               
                  | ({32{ea[1]==1'b1}} & {{16{mem_input[31]}},mem_input[31:16]});

assign lhu_result = ({32{ea[1]==1'b0}} & {{16'd0},mem_input[15: 0]})
                  | ({32{ea[1]==1'b1}} & {{16'd0},mem_input[31:16]});


assign mem_output = ({32{control_code[0]}} & lw_result )
                  | ({32{control_code[1]}} & lb_result )
                  | ({32{control_code[2]}} & lbu_result)
                  | ({32{control_code[3]}} & lh_result )
                  | ({32{control_code[4]}} & lhu_result); 

wire [3:0] sw_strb ;
wire [3:0] sb_strb ;
wire [3:0] sh_strb ;

assign sw_strb  = 4'b1111;

assign sb_strb  = ({4{ea==2'b00}} & 4'b0001)
                | ({4{ea==2'b01}} & 4'b0010)
                | ({4{ea==2'b10}} & 4'b0100)
                | ({4{ea==2'b11}} & 4'b1000);

assign sh_strb  = ({4{ea[1]==1'b0}} & 4'b0011)
                | ({4{ea[1]==1'b1}} & 4'b1100);


assign write_strb = ({4{control_code[5]}} & sw_strb )
                  | ({4{control_code[6]}} & sb_strb )
                  | ({4{control_code[7]}} & sh_strb );

wire [31:0] sw_result ;
wire [31:0] sb_result ;
wire [31:0] sh_result ;


assign sw_result  = reg_input;

assign sb_result  = ({32{ea[1:0]==2'b00}} & {24'd0,reg_input[ 7: 0]      })
                  | ({32{ea[1:0]==2'b01}} & {16'd0,reg_input[ 7: 0], 8'd0})
                  | ({32{ea[1:0]==2'b10}} & { 8'd0,reg_input[ 7: 0],16'd0})
                  | ({32{ea[1:0]==2'b11}} & {      reg_input[ 7: 0],24'd0});

assign sh_result  = ({32{ea[1]==1'b0 }} & {16'd0,reg_input[15: 0]})
                  | ({32{ea[1]==1'b1 }} & {reg_input[15: 0],16'd0});

assign reg_output = ({32{control_code[5]}} & sw_result )
                  | ({32{control_code[6]}} & sb_result )
                  | ({32{control_code[7]}} & sh_result );


endmodule
