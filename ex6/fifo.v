`default_nettype none
module fifo #(parameter WIDTH=32, parameter DEPTH=8) (input wire clk, input wire res_n,
                                                      input wire[WIDTH-1:0] wdata, output wire[WIDTH-1:0] rdata,
                                                      input wire shift_in, input wire shift_out,
                                                      output reg full, output reg empty
                                                     );
`include "log.v"
parameter ADDR_SIZE = log2(DEPTH);
parameter ADDR_MAX  = DEPTH-1;
function incr_ptr(input[ADDR_SIZE-1:0] ptr);
begin
				if(ptr == ADDR_MAX)
					incr_ptr = {ADDR_SIZE{1'b0}};
				else
					incr_ptr = ptr+1;
end
endfunction

//{{{Debug output

`ifdef DEBUG
always @(posedge clk)
begin
	if(full == 1'b1 && shift_in == 1'b1 && res_n == 1'b1)
		$display("%c[1;33m%m: Dropping 0x%h, because the FIFO is full.%c[0m", 27, wdata, 27);
	if(empty == 1'b1 && shift_out == 1'b1 && res_n == 1'b1)
		$display("%c[1;33m%m: Returning invalid value due to readout of empty FIFO.%c[0m", 27, 27);
	if(res_n == 1'b0 && (shift_in == 1'b1 || shift_out == 1'b1))
		$display("%c[1;33m%m: Trying to access FIFO while it is in reset.%c[0m", 27, 27);
end
`endif
//}}}


reg[ADDR_SIZE-1:0] write_ptr;
reg[ADDR_SIZE-1:0] read_ptr;
wire write_enable;

ram #(.WIDTH(WIDTH), .SIZE(DEPTH)) ram_I (.clk(clk),
                                          .cs_a(write_enable), .we_a(1'b1), // Port A is used for writing
                                          .addr_a(write_ptr), .data_a(wdata),
                                          .cs_b(1'b1), .we_b(1'b0), // Port B is used for reading and is always
                                          .addr_b(read_ptr), .data_b(rdata) // activated
                                         );

assign write_enable = shift_in && !full;

always @(posedge clk or negedge res_n)
begin
	if(!res_n)
	begin
		write_ptr <= {ADDR_SIZE{1'b0}};
		read_ptr  <= {ADDR_SIZE{1'b0}};
		full      <= 1'b0;
		empty     <= 1'b1;
	end
	case({shift_in,shift_out})
		2'b00: // Do nothing
		begin
			write_ptr <= write_ptr;
			read_ptr  <= read_ptr;
			full      <= full;
			empty     <= empty;
		end
		2'b01: // All register stages shift one forward.
		begin
			if(!empty)
			begin
				read_ptr <= incr_ptr(read_ptr);
				if(incr_ptr(read_ptr) == write_ptr)
					empty <= 1'b1;
			end
		end
		2'b10: // Fill in a new value without shifting.
		begin
			if(!full)
			begin
				write_ptr <= incr_ptr(write_ptr);
				if(incr_ptr(write_ptr) == read_ptr)
					full <= 1'b1;
			end
		end
		2'b11: // Fill and Read at the same time
		begin
		end
	endcase

end




















//wire[WIDTH-1:0] data [DEPTH:0];
//wire[DEPTH+1:0] filled;
//
//assign full  = filled[1];
//assign empty = !filled[DEPTH];
//
//`ifdef DEBUG
//assign data[0] = {WIDTH{1'b1}}; // For debugging: If there are all ones, they must have come from here...
//`else
//assign data[0] = {WIDTH{1'b0}}; // ... in normal operation, zeros are more common.
//`endif
//assign rdata = data[DEPTH];
//assign filled[0]       = 1'b0;
//assign filled[DEPTH+1] = 1'b1;
//
//generate
//	genvar i;
//	for(i=0; i<DEPTH; i=i+1)
//	begin : foobar
//		//$display("asdf");
//		register_stage #(.WIDTH(WIDTH)) stage_I (.clk(clk), .res_n(res_n),
//		                                         .fill_in(wdata), .fwd_in(data[i]), .data_out(data[i+1]),
//		                                         .shift_in(shift_in), .shift_out(shift_out),
//		                                         .prev_filled(filled[i]), .filled(filled[i+1]), .next_filled(filled[i+2])
//		                                        );
//	end
//endgenerate
//
//
//
//`ifdef VERBOSE
//integer j;
//always @(posedge clk)
//begin
//	#1
//	$write("%c[1;34m%m: STATUS:", 27);
//	if(shift_in == 1'b1)
//		$write(" => %h ", wdata);
//	else
//		$write(" -> %h ", wdata);
//	for (j = 1; j != DEPTH+1; j = j + 1)
//	begin
//		if(filled[j] == 1'b1)
//			$write("■");
//		else
//			$write("◻");
//	end
//	if(shift_out == 1'b1)
//		$write(" => %h", rdata);
//	else
//		$write(" -> %h", rdata);
//	if(full == 1'b1)
//		$write(" FULL");
//	if(empty == 1'b1)
//		$write(" EMPTY");
//	if(res_n == 1'b0)
//		$write(" RESET");
//	$display("%c[0m", 27);
//end
//`endif

endmodule
