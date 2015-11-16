// Clock Module

module clk_out(output reg clk);
	initial begin
		clk = 0;
	end

	always
	begin
		#5 clk = ~clk;
	end
endmodule
