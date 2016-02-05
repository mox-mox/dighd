module ram #(parameter SIZE=16, parameter WIDTH=16) (input wire clk,
                                                     input wire cs_a, input wire we_a,
                                                     input tri[log2(SIZE)-1:0] addr_a,
                                                     inout wire[WIDTH-1:0] data_a,
                                                     input wire cs_b, input wire we_b,
                                                     input wire[log2(SIZE)-1:0] addr_b,
                                                     inout tri[WIDTH-1:0] data_b
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
end
`endif
//}}}



reg [WIDTH-1:0] mem [SIZE-1:0];
reg [WIDTH-1:0] data_out_a;
reg [WIDTH-1:0] data_out_b;

`ifdef VERBOSE
always @(posedge clk)
begin: ram_verbose
	//integer j;
	reg[log2(SIZE)-1:0] j;
	//#2 $write("%c[1;34m%m: STATUS: | ", 27);
	#2 $write(" | ");
	for (j = 0; j != SIZE-1; j = j + 1)
	begin
		if(j==addr_a)
			$write(">>");
		else
			$write("  ");
		$write("%h", mem[j]);
		if(j==addr_b)
			$write(">>");
		else
			$write("  ");
		$write("|");
	end
	//$display("%c[0m", 27);
end
`endif

assign data_a = (cs_a && !we_a) ? data_out_a : {WIDTH{1'bz}};
assign data_b = (cs_b && !we_b) ? mem[addr_b] : {WIDTH{1'bz}};
//assign data_b = (cs_b && !we_b) ? data_out_b : {WIDTH{1'bz}};

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
			//data_out_b <= mem[incr_ptr(addr_b)]; // HACKY. TODO: Improve this.
		end
	end
	else
	begin: NOP_B
		data_out_b <= {WIDTH{1'b0}};
	end
end
endmodule
