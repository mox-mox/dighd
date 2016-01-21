module lfsr_tb();

reg [32:0] simulation_step;
reg clk;
reg res_n;
reg enable;
reg clear;
wire d_out;
reg one;

	parameter TESTSTEPS = 100;
	reg[TESTSTEPS-1:0] shifter_nominal_output = 100'b1000101100000000101001011000111000001010011000100001101001001001000001000001100000001001000000000001;
	lfsr #(.width(57), .polynomial(57'b1000000000001001000000010000000000000000000000100000000001)) lfsr_I(
	                                                                                                       .clk(clk),
	                                                                                                       .res_n(res_n),
	                                                                                                       .enable(enable),
	                                                                                                       .clear(clear),
	                                                                                                       .d_out(d_out)
	                                                                                                      );


// Nach 10 Takten: 56'h003FFE_01BF8FFF



initial begin
	//$monitor("feedback: %h, forward: %h, out: %h", feedback, forward, out);
	$monitor("res_n: $h", res_n);
	simulation_step=0;
	res_n <= 1;
	enable <=0;
	clear <=0;
	#1;
	res_n <= 0;
	#4;
	res_n <= 1;
	$display(" ==== Starting ====");
	#10;
	enable <= 1;
	#10;
	#10;
	#10;
	#10;
	#10;
	#10;
	#10;






	#10;
	#10;
	$stop;
end

always
begin
	$display("Posedge clk");
	simulation_step <= simulation_step+1;
	clk=1;
	$display("d_out: %h", d_out);
	#5;
	clk=0;
	#5;
end

always
begin
		one = !d_out^shifter_nominal_output[simulation_step]; // The blocking assignment is mandatory here.
		$display ("Time: %3d, Soll: %b, Ist: %b, One: %b", simulation_step[31:0], shifter_nominal_output[simulation_step], d_out, one);
end



endmodule
