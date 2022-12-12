module divisor_top
(
	input clk,reset_n,
	input start,
	output ready,
	output [3:0] sel,
	output [7:0] sseg
);

wire [7:0] rem,quo;
wire start_db;

db_fsm db_fsm_inst
(
	.clk(clk),
	.reset_n(reset_n),
	.sw(!start),
	.db(start_db)
);

sseg_time_mux sseg_time_mux_inst
(
	.clk(clk),
	.hex0(quo[3:0]),.hex1(rem[3:0]),.hex2(0),.hex3(0),
	.dp(4'b1110),
	.sel(sel),
	.sseg(sseg)
);
divisor div_inst (
	.clk(clk),.reset_n(reset_n),
	.start(start_db),
	.dvnd(8'b00001111),.dvsr(1),
	.ready(ready),
	.rem(rem),.quo(quo)
);

endmodule