// Linear Shift Register Type Two (Galois LFSR) (XOR in forward path)
module lfsr #(parameter width=32, parameter [width-1:0] polynomial={width{1'b0}}) (
	                                                             input wire clk,
                                                                 input wire res_n,
                                                                 input wire enable,
                                                                 input wire clear,
                                                                 output wire d_out
                                                                );
	wire feedback;
	wire [width-1:1] w;
	register_stage#(.with_xor(0)) rs_first_I(.clk(clk), .res_n(res_n), .forward(feedback), .feedback(feedback), .out(w[1]));
	generate
		genvar i;
		for(i=1; i<width-1; i=i+1)
		begin: regstage
			register_stage#(.with_xor(polynomial[i])) rs_middle_I(.clk(clk), .res_n(res_n), .forward(w[i]), .feedback(feedback), .out(w[i+1]));
		end
	endgenerate
	register_stage#(.with_xor(0)) rs_last_I(.clk(clk), .res_n(res_n), .forward(w[width-1]), .feedback(feedback), .out(feedback));
	assign d_out = feedback;
endmodule
