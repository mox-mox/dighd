// Test Bench for the register stage

module register_stage_tb();

reg feedback;
reg forward;
reg clk;
reg res_n;
wire out;

register_stage#(.with_xor(0)) register_stage_I(.clk(clk), .res_n(res_n), .forward(forward), .feedback(feedback), .out(out)); // should be a simple flipflop

initial begin
	$monitor("feedback: %h, forward: %h, out: %h", feedback, forward, out);
	feedback <= 0;
	forward <= 0;
	res_n <= 0;
	#5;
	res_n <= 1;
	$display(" ==== Starting ====");
	#10;
	feedback <= 0;
	forward <= 0;
	#10;
	feedback <= 1;
	forward <= 0;
	#10;
	feedback <= 1;
	forward <= 0;
	#10;
	feedback <= 0;
	forward <= 0;
	#10;
	feedback <= 0;
	forward <= 1;
	#10;
	feedback <= 0;
	forward <= 1;
	#10;
	feedback <= 0;
	forward <= 0;
	#10;
	feedback <= 0;
	forward <= 0;
	#10;
	feedback <= 1;
	forward <= 1;
	#10;
	feedback <= 1;
	forward <= 1;
	#10;
	feedback <= 0;
	forward <= 0;
	#10;
	feedback <= 0;
	forward <= 0;






	#10;
	#10;
	$finish;
end

always
begin
	$display("Posedge clk");
	clk=1;
	#5;
	clk=0;
	#5;
end





endmodule
