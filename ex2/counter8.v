// This should implement an 8Bit counter
// Adapted from the script at page 30


module counter8(input wire clk, input wire res_n, input wire enable, input wire clear, output reg [7:0] cnt_out);
	always @(posedge clk or negedge res_n) begin
		if(res_n == 1'b0 || clear == 1'b1) begin
			cnt_out <= 8'h00;
		end else if(enable == 1'b1) begin
			cnt_out <= cnt_out + 1'b1;
		//end else bein
		//	cnt_out <= cnt_out;
		end
	end
endmodule

