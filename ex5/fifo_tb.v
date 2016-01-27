`default_nettype none
`timescale 10ns/1ns

module fifo_tb;
parameter TESTWIDTH=8;
parameter TESTDEPTH=3;
	//{{{
	/* Make a regular pulsing clock. */
	parameter clk_period=1;
	parameter half_clk_period=clk_period*0.5;
	reg clk = 1;
	always begin
		#half_clk_period
		//$display("clk \\");
		clk = 1'b0;

		#half_clk_period
		$display("clk /");
		clk = 1'b1;
	end
	//}}}




	/* Make a reset that pulses once. */
	reg res_n = 0;

	reg[TESTWIDTH-1:0] indata={TESTWIDTH{1'b0}};
	wire[TESTWIDTH-1:0] outdata;
	reg shift_in;
	reg shift_out;
	wire full;
	wire empty;

	fifo #(.WIDTH(TESTWIDTH), .DEPTH(TESTDEPTH)) fifo_I(.clk(clk), .res_n(res_n),
	                                            .wdata(indata), .rdata(outdata),
	                                            .shift_in(shift_in), .shift_out(shift_out),
	                                            .full(full), .empty(empty)
	                                           );






	initial begin
	$dumpfile("fifo.vcd");
	$dumpvars(0, fifo_tb);
	shift_in  <= 0;
	shift_out <= 0;
	#half_clk_period
	res_n <= 1;
	$display("STARTING NORMAL TEST:");
	shift_in <= 1;
	indata <= 8'h12;
	#clk_period
	shift_in <= 1;
	indata <= 8'h34;
	#clk_period
	shift_in <= 1;
	indata <= 8'h56;
	#clk_period
	shift_in <= 1;
	indata <= 8'h78;
	#clk_period
	shift_in <= 1;
	indata <= 8'h9a;
	#clk_period
	shift_in <= 0;
	shift_out <= 1;
	#clk_period
	#clk_period
	#clk_period
	#clk_period
	#clk_period
	#clk_period
	#clk_period
	#clk_period
	shift_out <= 0;



	#10 $finish;
	end


	always @(outdata, full, empty) begin
		if(full == 1'b0 && empty == 1'b0)
			$display("%t: output=%h",$time, outdata);
		if(full == 1'b0 && empty == 1'b1)
			$display("%t: output=%h EMPTY",$time, outdata);
		if(full == 1'b1 && empty == 1'b0)
			$display("%t: output=%h FULL",$time, outdata);
		if(full == 1'b1 && empty == 1'b1)
			$display("%t: output=%h FULL EMPTY",$time, outdata);
	end





	//initial $monitor("%t: output: %h (%0d)", $time, outdata, value);



endmodule
