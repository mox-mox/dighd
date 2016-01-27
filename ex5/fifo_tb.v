`default_nettype none
`timescale 1ns/1ns
module fifo_tb;
parameter WIDTH=8;
parameter DEPTH=8;
	//{{{
	/* Make a regular pulsing clock. */
	parameter clk_period=1;
	parameter half_clk_period=clk_period*0.5;
	reg clk = 1;
	always begin
		#half_clk_period
		$display("clk1 \\");
		clk = 1'b0;

		#half_clk_period
		$display("clk1 /");
		clk = 1'b1;
	end
	//}}}




	/* Make a reset that pulses once. */
	reg res_n = 0;

	reg[WIDTH-1:0] indata;
	wire[WIDTH-1:0] outdata;
	reg shift_in;
	reg shift_out;
	wire full;
	wire empty;

	fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) fifo_I(.clk(clk), .res_n(res_n),
	                                            .wdata(indata), .rdata(outdata),
	                                            .shift_in(shift_in), .shift_out(shift_out),
	                                            .full(full), .empty(empty)
	                                           );






	initial begin
	$dumpfile("fifo.vcd");
	$dumpvars(0, fifo_tb);

		 #17 reset = 1;
		 #11 reset = 0;
		 #29 reset = 1;
		 #5  reset =0;
		 #513 $finish;
	end







	initial
	$monitor("At time %t, value = %h (%0d)",
	         $time, value, value);



endmodule
