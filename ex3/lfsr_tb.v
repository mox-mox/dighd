// Testbench for the counter


module lfsr_tb();

	parameter TESTWIDTH = 5;

	wire clock;
	wire shifter_data;
	reg reset_n;
	reg cnt_en;
	reg cnt_clear;


	clk_out clock_I(.clk(clock));

	lfsr #(.width(TESTWIDTH), .polynomial(01010)) lfsr_I(
	                                                               .clk(clock),
	                                                               .res_n(reset_n),
	                                                               .enable(cnt_en),
	                                                               .clear(cnt_clear),
	                                                               .d_out(shifter_data)
	                                                              );
	initial begin
		reset_n   <= 0;
		cnt_clear <= 0;
		cnt_en    <= 0;
		#10
		reset_n <= 1;
		cnt_en  <= 1;





		#1000 $stop;
	end
endmodule
