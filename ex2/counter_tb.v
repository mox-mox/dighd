// Testbench for the counter


module counter_tb();

	parameter TESTWIDTH = 4;

	wire clock;
	wire [TESTWIDTH-1:0] count;
	reg reset_n;
	reg cnt_en;
	reg cnt_clear;
	
	
	clk_out clock_I(.clk(clock));

	counter #(.width(TESTWIDTH)) counter_I(
			                       .clk(clock),
			                       .res_n(reset_n),
			                       .enable(cnt_en),
			                       .clear(cnt_clear),
			                       .cnt_out(count)
			                      );
	initial begin
		reset_n <= 0;
		//clock <= 1'b0;
		cnt_en <= 1;
		cnt_clear <= 0;
		#100
		reset_n = 1;
	end
endmodule
