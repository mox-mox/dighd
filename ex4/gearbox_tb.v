`default_nettype none
module gearbox_tb();
	parameter clk1_quarter   = 2;
	parameter clk1_half_period   = 4;
	parameter clk2_half_period   = 5;
	parameter clk1_period        = 8;
	parameter clk2_period        = 10;
	reg res_n;
	reg clk1;
	reg clk2;

	reg shift_in;
	reg shift_out;
	reg [15:0] data_in;

	wire valid_out;
	wire full;
	wire[19:0] data_out;

	gearbox Gearbox(
	/*input wire*/        .clk1(clk1),
	/*input wire*/        .res_n(res_n),
	/*output reg*/        .full(full),
	/*input wire*/        .shift_in(shift_in),
	/*input wire[15:0]*/  .data_in(data_in),
	/*input wire*/        .clk2(clk2),
	/*output reg*/        .valid_out(valid_out),
	/*input wire*/        .shift_out(shift_out),
	/*output wire[19:0]*/ .data_out(data_out));


	initial begin
		res_n                 <=  1'h0;
		clk1                  <=  1'h0;
		clk2                  <=  1'h0;
		{shift_in, shift_out} <=  2'h0;
		data_in[15:0]         <=  1'h0;
		#clk1_quarter;
		#clk1_half_period;
		res_n                 <=  1'h1;
		$display("Starting Simulation");
		$display("Test 1: Empty buffer stream through");
		{shift_in, shift_out} <= 2'h3;
		data_in[15:0]         <= 16'h5555;
		@(posedge clk1)
		if({valid_out, full} !== 2'b00) begin $display("		(EE): output wrong"); $finish; end
		#clk1_half_period;
		data_in[15:0]         <= 16'haaaa;
		@(posedge clk2)
		#1
		$display("data_out: %20b", data_out[19:0]);
		//if({valid_out, full} !== 2'b10) begin $display("		(EE): Failed to set valid_out"); $finish; end


	end
	initial begin
		#1000 $finish;
	end












	always begin
		//#10
		#clk1_period clk1 = ~clk1;
		$display("clk1 /");
	end
	always begin
		//#10
		#clk2_period clk2 = ~clk2;
		$display("	clk2 /");
	end
endmodule
