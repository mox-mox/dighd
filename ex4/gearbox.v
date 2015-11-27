module lfsr (
	         input wire clk1,
             input wire res_n,
             output reg full,
             input wire shift_in,
             input wire[15:0] data_in,

			 input wire clk2,
			 output reg valid_out, // Also: Empty signal
			 input wire shift_out,
			 output wire[19:0] data_out
            );

	reg[159:0] fifo;
	reg[3:0] fifo_input_idx;
	reg[2:0] fifo_output_idx;

	always @(negedge res_n) begin
		fifo[159:0]          <= {160{1'b0}};
		fifo_input_idx[3:0]  <= {4{1'b0}};
		fifo_output_idx[2:0] <= {3{1'b0}};
		full                 <= 1'b0;
		valid_out            <= 1'b0;
	end

	always @(posedge clk1) begin
		if(shift_in && !full) begin
			case(fifo_input_idx[3:0]) // synopsys full_case parallel_case
				4'h0: if(output_idx[2:0] != 3'h0 || !valid_out) begin fifo[ 15:  0] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h1; if(output_idx[2:0] == 3'h1) begin full <= 1'b1; end                    end
				4'h1: if(output_idx[2:0] != 3'h1 || !valid_out) begin fifo[ 31: 16] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h2; if(output_idx[2:0] == 3'h2) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h2: if(output_idx[2:0] != 3'h2 || !valid_out) begin fifo[ 47: 32] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h3; if(output_idx[2:0] == 3'h3) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h3: if(output_idx[2:0] != 3'h3 || !valid_out) begin fifo[ 63: 48] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h4;                                                     valid_out <= 1'b1; end
				4'h4: if(output_idx[2:0] != 3'h4 || !valid_out) begin fifo[ 79: 64] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h5; if(output_idx[2:0] == 3'h4) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h5: if(output_idx[2:0] != 3'h1 || !valid_out) begin fifo[ 95: 80] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h6; if(output_idx[2:0] == 3'h5) begin full <= 1'b1; end                    end
				4'h6: if(output_idx[2:0] != 3'h1 || !valid_out) begin fifo[111: 96] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h7; if(output_idx[2:0] == 3'h6) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h7: if(output_idx[2:0] != 3'h1 || !valid_out) begin fifo[127:112] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h8; if(output_idx[2:0] == 3'h7) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h8: if(output_idx[2:0] != 3'h1 || !valid_out) begin fifo[143:128] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h9;                                                     valid_out <= 1'b1; end
				4'h9: if(output_idx[2:0] != 3'h1 || !valid_out) begin fifo[159:144] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h0; if(output_idx[2:0] == 3'h8) begin full <= 1'b1; end valid_out <= 1'b1; end
				default:
					$display("(EE): Gearbox write index reached unexpected value.");
			endcase
		end
		else
			$display("(EE): Trying to push stuff into the Gearbox while it was full.");
	end
	always @(posedge clk2) begin
		if(shift_out && valid_out) begin
			case(fifo_output_idx[2:0]) // synopsys full_case parallel_case
				// Valid_set -> we have to deliver on demand      increase the read pointer    Check if the fifo became empty...         The fifo cannot be full after reading.
				3'h0: begin data_out[19:0] <= new_data[ 19:  0]; fifo_output_idx[2:0] <= 3'h1; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
				3'h1: begin data_out[19:0] <= new_data[ 39: 20]; fifo_output_idx[2:0] <= 3'h2; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
				3'h2: begin data_out[19:0] <= new_data[ 59: 40]; fifo_output_idx[2:0] <= 3'h3; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
				3'h3: begin data_out[19:0] <= new_data[ 79: 60]; fifo_output_idx[2:0] <= 3'h4; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
				3'h4: begin data_out[19:0] <= new_data[ 99: 80]; fifo_output_idx[2:0] <= 3'h5; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
				3'h5: begin data_out[19:0] <= new_data[119:100]; fifo_output_idx[2:0] <= 3'h6; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
				3'h6: begin data_out[19:0] <= new_data[139:120]; fifo_output_idx[2:0] <= 3'h7; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
				3'h7: begin data_out[19:0] <= new_data[159:140]; fifo_output_idx[2:0] <= 3'h0; if(input_idx[3:0] == 4'h0) begin valid_out <= 1'b0; end full <=1'b1; end
			endcase
		end










endmodule

