module gearbox (
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
	assign data_out[19:0] = (fifo_output_idx[2:0] == 3'h0) ? fifo[ 19:  0]:
	                        (fifo_output_idx[2:0] == 3'h1) ? fifo[ 39: 20]:
	                        (fifo_output_idx[2:0] == 3'h2) ? fifo[ 59: 40]:
	                        (fifo_output_idx[2:0] == 3'h3) ? fifo[ 79: 60]:
	                        (fifo_output_idx[2:0] == 3'h4) ? fifo[ 99: 80]:
	                        (fifo_output_idx[2:0] == 3'h5) ? fifo[119:100]:
	                        (fifo_output_idx[2:0] == 3'h6) ? fifo[139:120]:
	                      /*(fifo_output_idx[2:0] == 3'h7)?*/fifo[159:140];

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
				// If there is space and new data, fill the fifo...                                        Increase write pointer...    Detect if the fifo is full...                       Fifo cannot be empty after writing.
				4'h0: if(fifo_output_idx[2:0] != 3'h0 || !valid_out) begin fifo[ 15:  0] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h1; if(fifo_output_idx[2:0] == 3'h1) begin full <= 1'b1; end                    end
				4'h1: if(fifo_output_idx[2:0] != 3'h1 || !valid_out) begin fifo[ 31: 16] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h2; if(fifo_output_idx[2:0] == 3'h2) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h2: if(fifo_output_idx[2:0] != 3'h2 || !valid_out) begin fifo[ 47: 32] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h3; if(fifo_output_idx[2:0] == 3'h3) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h3: if(fifo_output_idx[2:0] != 3'h3 || !valid_out) begin fifo[ 63: 48] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h4;                                                          valid_out <= 1'b1; end
				4'h4: if(fifo_output_idx[2:0] != 3'h4 || !valid_out) begin fifo[ 79: 64] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h5; if(fifo_output_idx[2:0] == 3'h4) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h5: if(fifo_output_idx[2:0] != 3'h1 || !valid_out) begin fifo[ 95: 80] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h6; if(fifo_output_idx[2:0] == 3'h5) begin full <= 1'b1; end                    end
				4'h6: if(fifo_output_idx[2:0] != 3'h1 || !valid_out) begin fifo[111: 96] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h7; if(fifo_output_idx[2:0] == 3'h6) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h7: if(fifo_output_idx[2:0] != 3'h1 || !valid_out) begin fifo[127:112] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h8; if(fifo_output_idx[2:0] == 3'h7) begin full <= 1'b1; end valid_out <= 1'b1; end
				4'h8: if(fifo_output_idx[2:0] != 3'h1 || !valid_out) begin fifo[143:128] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h9;                                                          valid_out <= 1'b1; end
				4'h9: if(fifo_output_idx[2:0] != 3'h1 || !valid_out) begin fifo[159:144] <= data_in[15:0]; fifo_input_idx[3:0] <= 4'h0; if(fifo_output_idx[2:0] == 3'h0) begin full <= 1'b1; end valid_out <= 1'b1; end
				//default:
				//	$display("(EE): Gearbox write index reached unexpected value.");
			endcase
		end
	end
	always @(posedge clk2) begin
		if(shift_out && valid_out) begin
			case(fifo_output_idx[2:0]) // synopsys full_case parallel_case
				//          Increase the read pointer...  Check if the fifo became empty...                                                  Fifo cannot be full after reading.
				3'h0: begin fifo_output_idx[2:0] <= 3'h1; if(fifo_input_idx[3:0] == 4'h2                                ) begin valid_out <= 1'b0; end full <=1'b0; end
				3'h1: begin fifo_output_idx[2:0] <= 3'h2; if(fifo_input_idx[3:0] == 4'h3                                ) begin valid_out <= 1'b0; end full <=1'b0; end
				3'h2: begin fifo_output_idx[2:0] <= 3'h3; if(fifo_input_idx[3:0] == 4'h4                                ) begin valid_out <= 1'b0; end full <=1'b0; end
				3'h3: begin fifo_output_idx[2:0] <= 3'h4; if(fifo_input_idx[3:0] == 4'h5 || fifo_input_idx[3:0] == 4'h6 ) begin valid_out <= 1'b0; end full <=1'b0; end
				3'h4: begin fifo_output_idx[2:0] <= 3'h5; if(fifo_input_idx[3:0] == 4'h7                                ) begin valid_out <= 1'b0; end full <=1'b0; end
				3'h5: begin fifo_output_idx[2:0] <= 3'h6; if(fifo_input_idx[3:0] == 4'h8                                ) begin valid_out <= 1'b0; end full <=1'b0; end
				3'h6: begin fifo_output_idx[2:0] <= 3'h7; if(fifo_input_idx[3:0] == 4'h9                                ) begin valid_out <= 1'b0; end full <=1'b0; end
				3'h7: begin fifo_output_idx[2:0] <= 3'h0; if(fifo_input_idx[3:0] == 4'h0 || fifo_input_idx[3:0] == 4'h1 ) begin valid_out <= 1'b0; end full <=1'b0; end
			endcase
		end
	end
endmodule

