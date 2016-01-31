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
		//$display("asdf");
		register_stage #(.WIDTH(WIDTH)) stage_I (.clk(clk), .res_n(res_n),
		                           .fill_in(wdata), .fwd_in(data[i]), .data_out(data[i+1]),
		                           .shift_in(shift_in), .shift_out(shift_out),
		                           .prev_filled(filled[i]), .filled(filled[i+1]), .next_filled(filled[i+2])
		                          );
	end
endgenerate


`ifdef DEBUG
always @(posedge clk)
begin
	if(full == 1'b1 && shift_in == 1'b1)

		$display("%c[1;31m%m: Dropping 0x%h, because the FIFO is full.%c[0m", 27, wdata, 27);
	if(empty == 1'b1 && shift_out == 1'b1)
		$display("%c[1;31m%m: Returning invalid value due to readout of empty FIFO.%c[0m", 27, 27);
end
`endif

`ifdef VERBOSE

integer j;
always @(posedge clk)
begin
	$write("%c[1;34m%m: STATUS:", 27);
	if(shift_in == 1'b1)
		$write(" => %h ", wdata);
	else
		$write(" -> %h ", wdata);
	for (j = 1; j != DEPTH+1; j = j + 1)
	begin
		if(filled[j] == 1'b1)
			$write("■");
		else
			$write("◻");
	end
	if(shift_out == 1'b1)
		$write(" => %h", rdata);
	else
		$write(" -> %h", rdata);
	if(full == 1'b1)
		$write(" FULL");
	if(empty == 1'b1)
		$write(" EMPTY");
	if(res_n == 1'b0)
		$write(" RESET");
	$display("%c[0m", 27);
end
`endif

endmodule
