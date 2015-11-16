// Testbench for the counter


module counter_tb();

	wire clock;
	wire [7:0] count;
	reg reset_n;
	reg cnt_en;
	reg cnt_clear;
	
	
	clk_out clock_I(.clk(clock));

	counter8 counter_I(
			.clk(clock),
			.res_n(reset_n),
			.enable(cnt_en),
			.clear(cnt_clear),
			.cnt_out(count)
			);
	initial begin
		reset_n <= 0;
		cnt_en <= 1;
		cnt_clear <= 0;
		#100
		reset_n = 1;
	end
endmodule
