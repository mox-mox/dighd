//////////////////////////////////////////////////////////////////////////////////
// Company:  Uni Heidelberg
// Engineer: Mox
//
//////////////////////////////////////////////////////////////////////////////////

module counter #(parameter width=32) (input wire clk, input wire res_n, input wire enable, input wire clear, output reg [width-1:0] cnt_out);
	always @(posedge clk or negedge res_n) begin
		if(res_n == 1'b0 || clear == 1'b1) begin
			cnt_out <= 0;
		end else if(enable == 1'b1) begin
			cnt_out <= cnt_out + 1'b1;
		end
	end
endmodule
