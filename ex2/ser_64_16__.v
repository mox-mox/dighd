// This is a 64bit to 16bit serialiser.
// 


module ser_64_16(input wire clk, input wire res_n,
                 input wire valid_in, output wire valid_out,
                 input wire  stop_in, output wire stop_out,

                 input wire[63:0] data_in, output reg [15:0] data_out
                );


	reg[2:0] state;
	parameter EMPTY= 3'b0_00;
	parameter FIRST= 3'b1_00;
	parameter SECOND=3'b1_11;
	parameter THIRD= 3'b1_10;
	parameter FOURTH=3'b1_11;
	assign valid_out=state[3];
	always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin // Go to idle state on reset.
			state <= EMPTY;
			// TODO: stop_out
		end
		else // posedge clk
		begin
			case(state)  // synopsys full_case
				EMPTY:
					if(valid_in == 1'b1) state <= FIRST;
					else state <= EMPTY;
				FIRST:
					if(stop_in == 1'b0) state <= SECOND;
					else state <= FIRST;
				SECOND:
					if(stop_in == 1'b0) state <= THIRD;
					else state <= SECOND;
				THIRD:
					if(stop_in == 1'b0) state <= FOURTH;
					else state <= THIRD;
				FOURTH:
					if(stop_in == 1'b0) state <= EMPTY;
					else state <= FOURTH;
			endcase
		end
	end

	reg[47:0] data;
	always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin
			data_out <= 16'h0000;
			data <= 48'b000000000000;
		end
		else // posedge clk
		begin

			case(state[1:0]) // synopsys full_case
				EMPTY:
					if(valid_in)
					begin
						data_out <= data_in[15:0];
						data <= data_in[63:16];
					end
					else
					begin
						data_out <= 16'h0000;
						data <= 48'b000000000000;
					end
				FIRST:
					data_out <= data[15:0];
				SECOND:
					data_out <= data[31:16];
				THIRD:
					data_out <= data[47:32];
				FOURTH:
					if(valid_in)
					begin
						data_out <= data_in[15:0];
						data <= data_in[63:16];
					end
					else
					begin
						data_out <= 16'h0000;
						data <= 48'b000000000000;
					end

			endcase



		end
	end
endmodule

