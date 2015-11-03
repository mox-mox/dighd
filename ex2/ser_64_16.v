// This is a 64bit to 16bit serialiser.
// 


module ser_64_16(input wire clk,
                 input wire res_n,
                 input wire valid_in,
                 output wire stop_out,
                 input reg[63:0] data_in,
                 output reg valid_out,
                 input reg stop_in,
                 output reg [15:0] data_out);
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

