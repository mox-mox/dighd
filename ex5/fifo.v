`default_nettype none
module fifo #(parameter WIDTH=32, parameter DEPTH=8) (input wire clk, input wire res_n,
                                                      input wire[WIDTH-1:0] wdata, output wire[WIDTH-1:0] rdata,
                                                      input wire shift_in, input wire shift_out,
                                                      output wire full, output wire empty
                                                     );

wire[WIDTH-1:0] data [DEPTH:0];
wire[DEPTH+1:0] filled;

assign full  = filled[1];
assign empty = !filled[DEPTH];

assign data[0] = {WIDTH{1'b1}}; // For debugging: If there are all ones, they must have come from here...
assign rdata = data[DEPTH];
assign filled[0]       = 1'b0;
assign filled[DEPTH+1] = 1'b1;



generate
	genvar i;
	for(i=0; i<DEPTH; i=i+1)
	begin : foobar
		register_stage #(.WIDTH(WIDTH)) stage_I (.clk(clk), .res_n(res_n),
		                           .fill_in(wdata), .fwd_in(data[i]), .data_out(data[i+1]),
		                           .shift_in(shift_in), .shift_out(shift_out),
		                           .prev_filled(filled[i]), .filled(filled[i+1]), .next_filled(filled[i+2])
		                          );
	end
endgenerate

endmodule
