module register_stage #(parameter WIDTH=32) (input wire clk, input wire res_n,
                                   input wire[WIDTH-1:0] fill_in, input wire[WIDTH-1:0] fwd_in, output reg[WIDTH-1:0] data_out,
                                   input wire shift_in, input wire shift_out,
                                   input wire prev_filled, output reg filled, input wire next_filled
                                  );

always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin
			data_out <= {WIDTH{1'b0}};
			filled <= 1'b0;
		end
		else
		begin
			case({shift_in,shift_out})
				2'b00: // Do nothing
				begin
					data_out <= data_out;
					filled <= filled;
				end
				2'b01: // All register stages shift one forward.
				begin
					data_out <= fwd_in;
					filled <= prev_filled;
				end
				2'b10: // Fill in a new value without shifting.
				begin
					if(prev_filled == 1'b0 && filled == 1'b0 && next_filled == 1'b1)
					begin // Fill in if this stage is the first empty one ...
						data_out <= fill_in;
						filled <= 1'b1;
					end
					else
					begin // ... and keep the old value if either filled, or empty but not the first empty one.
						data_out <= data_out;
						filled <= filled;
					end
				end
				2'b11:
				begin
					if(prev_filled == 1'b0 && filled == 1'b1 && next_filled == 1'b1)
					begin // Fill in if this stage WILL be the first empty one ...
						data_out <= fill_in;
						filled <= 1'b1;
					end
					else
					begin // ... or shift the value
						data_out <= fwd_in;
						filled <= prev_filled;
					end
				end
			endcase
		end
	end
endmodule






