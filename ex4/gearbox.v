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

	task FILL_FIFO;
		input [15:0] new_data;
		input [3:0] write_index;
		inout [159:0] buffer;
		begin
			case(write_index[3:0])// synopsys full_case
				4'h0: buffer[ 15:  0] <= new_data[15:0];
				4'h1: buffer[ 31: 16] <= new_data[15:0];
				4'h2: buffer[ 47: 32] <= new_data[15:0];
				4'h3: buffer[ 63: 48] <= new_data[15:0];
				4'h4: buffer[ 79: 64] <= new_data[15:0];
				4'h5: buffer[ 95: 80] <= new_data[15:0];
				4'h6: buffer[111: 96] <= new_data[15:0];
				4'h7: buffer[127:112] <= new_data[15:0];
				4'h8: buffer[143:128] <= new_data[15:0];
				4'h9: buffer[159:144] <= new_data[15:0];
			endcase
		end
	end

	task OUTPUT_FIFO;
		input [159:0] buffer;
		input [2:0] read_index;
		inout [19:0] output_data;
		begin
			case(write_index[3:0])// synopsys full_case
				'h0: buffer[15:0] <= new_data[ 15:  0];
				'h1: buffer[15:0] <= new_data[ 31: 16];
				'h2: buffer[15:0] <= new_data[ 47: 32];
				'h3: buffer[15:0] <= new_data[ 63: 48];
				'h4: buffer[15:0] <= new_data[ 79: 64];
				'h5: buffer[15:0] <= new_data[ 95: 80];
				'h6: buffer[15:0] <= new_data[111: 96];
				'h7: buffer[15:0] <= new_data[127:112];
			endcase
		end
	end





	always @(negedge res_n) begin
		fifo[159:0]          <= {160{1'b0}};
		fifo_input_idx[3:0]  <= {4{1'b0}};
		fifo_output_idx[2:0] <= {3{1'b0}};
		full                 <= 1'b0;
		valid_out            <= 1'b0;
	end

	always @(posedge clk1) begin
		if(shift_in && !full)
		begin
			case(fifo_input_idx[3:0]) // synopsys full_case parallel_case
				4'h0: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[ 15:  0] <= data_in[15:0];
				4'h1: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[ 31: 16] <= data_in[15:0];
				4'h2: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[ 47: 32] <= data_in[15:0];
				4'h3: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[ 63: 48] <= data_in[15:0];
				4'h4: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[ 79: 64] <= data_in[15:0];
				4'h5: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[ 95: 80] <= data_in[15:0];
				4'h6: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[111: 96] <= data_in[15:0];
				4'h7: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[127:112] <= data_in[15:0];
				4'h8: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[143:128] <= data_in[15:0];
				4'h9: if (output_idx[2:0] != 3'b001 || !valid_out) fifo[159:144] <= data_in[15:0];
				default:
					$display("(EE): Gearbox write index reached unexpected value.");
			endcase
		end



		if(shift_in && !full && (!valid_out || (fifo_input_idx[3:0]...)) begin


		end
	end









	always @(posedge clk1 or negedge res_n) begin
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

