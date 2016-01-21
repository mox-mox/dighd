module lfsr #(parameter width=32, parameter [width-1:0] polynomial={width{1'b0}}) (
	                                                             input wire clk,
                                                                 input wire res_n,
                                                                 input wire enable,
                                                                 input wire clear,
                                                                 output wire d_out
                                                                );
	reg[width-1:0] data;
	assign d_out = data[0];

	integer i;
	always @(posedge clk or negedge res_n) begin
		//$display ("lfsr data: %B", data[width-1:0]);
		if(res_n == 1'b0 || clear == 1'b1) begin
			data<={1'b1,{width-1{1'b0}}};
		end else if (enable == 1'b1) begin
			data[0] <= data[width-1];
			for(i=1; i!=width; i = i+1) begin
				data[i] <= polynomial[i] ? data[i-1]^data[width-1] : data[i-1];
			end
		end
	end
endmodule
