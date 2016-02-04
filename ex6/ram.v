module ram #(parameter SIZE=16, parameter WIDTH=16) (input wire clk,
                                                     input wire cs_a, input wire we_a,
                                                     input wire[log2(SIZE)-1:0] addr_a,
                                                     inout wire[WIDTH-1:0] data_a,
                                                     input wire cs_b, input wire we_b,
                                                     input wire[log2(SIZE)-1:0] addr_b,
                                                     inout wire[WIDTH-1:0] data_b
                                                    );

`include "log.v"

//{{{Debug output

`ifdef DEBUG
always @(posedge clk)
begin
	if(addr_a >= SIZE) // Only possible, if SIZE is not a power of two, but anyway.
		$display("%c[1;33m%m: addr_a is out of range (%h).%c[0m", 27, addr_a, 27);
	if(addr_b >= SIZE) // Only possible, if SIZE is not a power of two, but anyway.
		$display("%c[1;33m%m: addr_b is out of range (%h).%c[0m", 27, addr_b, 27);
	//if(!WE_a_n && !OE_a_n)
	//	$display("%c[1;33m%m: Control error: Both WE_a_n and OE_a_n are active.%c[0m", 27, 27);
	//if(!WE_b_n && !OE_b_n)
	//	$display("%c[1;33m%m: Control error: Both WE_b_n and OE_b_n are active.%c[0m", 27, 27);
end
`endif
//}}}


reg [WIDTH-1:0] mem [SIZE-1:0];
reg [WIDTH-1:0] data_out_a;
reg [WIDTH-1:0] data_out_b;

assign data_a = (cs_a && !we_a) ? data_out_a : {WIDTH{1'bz}};
assign data_b = (cs_b && !we_b) ? data_out_b : {WIDTH{1'bz}};

always @(posedge clk)
begin
	if(cs_a)
	begin: OPERATION_A
		if(we_a)
		begin: WRITE_A
			mem[addr_a] <= data_a;
			data_out_a  <= {WIDTH{1'b0}};
		end
		else
		begin: READ_A
			data_out_a <= mem[addr_a];
		end
	end
	else
	begin: NOP_A
		data_out_a <= {WIDTH{1'b0}};
	end

	if(cs_b)
	begin: OPERATION_B
		if(we_b)
		begin: WRITE_B
			mem[addr_b] <= data_b;
			data_out_b  <= {WIDTH{1'b0}};
		end
		else
		begin: READ_B
			data_out_b <= mem[addr_b];
		end
	end
	else
	begin: NOP_B
		data_out_b <= {WIDTH{1'b0}};
	end
end
endmodule
