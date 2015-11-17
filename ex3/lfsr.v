module lfsr #(parameter width=32, parameter [width-1:0] polynomial={width{1'b0}}) (
	                                                             input wire clk,
                                                                 input wire res_n,
                                                                 input wire enable,
                                                                 input wire clear,
                                                                 output wire d_out
                                                                );
	reg[width-1:0] data;
	assign d_out = data[width-1];

	integer i;
	always @(posedge clk or negedge res_n) begin
		if(res_n == 1'b0 || clear == 1'b1) begin
			data<={{width-1{1'b0}},1'b1};
		end else if (enable == 1'b1) begin
			data[0] <= d_out;
			for(i=1; i!=width; i = i+1) begin
				data[i] <= polynomial[i-1] ? data[i-1] ^ d_out : data[i-1];
			end
		end
	end
endmodule
