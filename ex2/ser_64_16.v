`default_nettype none
module ser_64_16 #(parameter INWIDTH=64, parameter OUTWIDTH=16) (input wire clk, input wire res_n,
                                                                 input wire[INWIDTH-1:0] wdata, output wire[OUTWIDTH-1:0] rdata,
                                                                 input wire valid_in, output wire valid_out,
                                                                 output wire stop_out, input wire stop_in
                                                                );

parameter DEPTH = INWIDTH/OUTWIDTH;
// Here should be an assert to ensure the division works without a remainder

wire[OUTWIDTH-1:0] data [DEPTH:0];
wire[DEPTH+1:0] filled;

assign valid_out=filled[DEPTH];
assign stop_out=stop_in?1'b1:filled[DEPTH-1]; // Vorletzte Stufe leer, dann kann im nächten Takt das nächste Datum kommen.


wire shift_out;
assign shift_out = !stop_in;
//assign shift_out = 1'b0;

wire shift_in;
assign shift_in = !filled[DEPTH-1] && !stop_in && valid_in;



`ifdef DEBUG
assign data[0] = {OUTWIDTH{1'b1}}; // For debugging: If there are all ones, they must have come from here...
`else
assign data[0] = {OUTWIDTH{1'b0}}; // ... in normal operation, zeros are more common.
`endif
assign rdata = data[DEPTH];
assign filled[0]       = 1'b0;
assign filled[DEPTH+1] = 1'b1;

generate
	genvar i;
	for(i=0; i<DEPTH; i=i+1)
	begin : foobar
		register_stage #(.WIDTH(OUTWIDTH)) stage_I (.clk(clk), .res_n(res_n),
		                                         .fill_in(wdata[OUTWIDTH*(i+1)-1:OUTWIDTH*i]), .fwd_in(data[i]), .data_out(data[i+1]),
		                                         .shift_in(shift_in), .shift_out(shift_out),
		                                         .prev_filled(filled[i]), .filled(filled[i+1]), .next_filled(filled[i+2])
		                                        );
	end
endgenerate


//{{{ Debug Information

//`ifdef DEBUG
//always @(posedge clk)
//begin
//	if(full == 1'b1 && shift_in == 1'b1 && res_n == 1'b1)
//		$display("%c[1;33m%m: Dropping 0x%h, because the FIFO is full.%c[0m", 27, wdata, 27);
//	if(empty == 1'b1 && shift_out == 1'b1 && res_n == 1'b1)
//		$display("%c[1;33m%m: Returning invalid value due to readout of empty FIFO.%c[0m", 27, 27);
//	if(res_n == 1'b0 && (shift_in == 1'b1 || shift_out == 1'b1))
//		$display("%c[1;33m%m: Trying to access FIFO while it is in reset.%c[0m", 27, 27);
//end
//`endif
//}}}

//{{{ Console output

`ifdef VERBOSE
integer j;
always @(posedge clk)
begin
	#1
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
	if(stop_out == 1'b1)
		$write(" STOP");
	if(valid_out == 1'b1)
		$write(" VALID");
	if(res_n == 1'b0)
		$write(" RESET");
	$display("%c[0m", 27);
end
`endif
//}}}

endmodule
