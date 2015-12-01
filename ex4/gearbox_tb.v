`default_nettype none
module gearbox_tb();
	reg res_n;
	reg clk1;
	reg clk2;

	reg shift_in;
	reg shift_out;
	reg [15:0] data_in;

	wire valid_out;
	wire[19:0] data_out;


	gearbox Gearbox(
	                .clk1(clk1),
	                .res_n(res_n),
	                .shift_in(shift_in),
	                .data_in(data_in),
	                .clk2(clk2),
	                .valid_out(valid_out),
	                .data_out(data_out)
	               );


	initial begin
		res_n         <= 0;
		clk1          <= 0;
		clk2          <= 0;
		shift_in      <= 0;
		shift_out     <= 0;
		data_in[15:0] <= 0;
		$display("Starting Simulation");
	end
	initial begin
		#1000 $stop;
	end












	always begin
		//#10
		#5 clk1 = ~clk1;
		$display("clk1 up");
	end
	always begin
		//#10
		#6 clk2 = ~clk2;
		$display("clk2 up");
	end
endmodule
