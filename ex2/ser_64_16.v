// This is a 64bit to 16bit serialiser.
// 


module ser_64_16(input wire clk, input wire res_n,
                 input wire valid_in, output reg valid_out,
                 input wire  stop_in, output reg stop_out,

                 input wire[63:0] data_in, output reg [15:0] data_out
                );


	reg[2:0] state;
	parameter EMPTY=3'b111;
	always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin // Go to idle state on reset.
			state <= 3'b111;
			valid_out <= 1'b0;
			stop_out <= 1'b0;
		end
		else // posedge clk
		begin
			case(state)  // synopsys full_case






		end
	end












	reg[47:0] data;
	always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin // Go to idle state on reset.
			// TODO
		end
		else // posedge clk
		begin



		end
	end
endmodule

