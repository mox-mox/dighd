module lfsr_tb();

reg clk;
reg res_n;
reg enable;
reg clear;
wire d_out;

lfsr#(.width(3),.polynomial(4'b111))  lfsr_I (.clk(clk), .res_n(res_n), .enable(enable), .clear(clear), .d_out(d_out));
initial begin
	//$monitor("feedback: %h, forward: %h, out: %h", feedback, forward, out);
	$monitor("res_n: $h", res_n);
	res_n <= 1;
	enable <=0;
	clear <=0;
	#1;
	res_n <= 0;
	#4;
	res_n <= 1;
	enable <= 1;
	$display(" ==== Starting ====");
	#10;
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
	clk=1;
	$display("d_out: %h", d_out);
	#5;
	clk=0;
	#5;
end



endmodule
