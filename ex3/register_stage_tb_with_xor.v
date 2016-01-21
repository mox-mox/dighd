// Test Bench for the register stage

module register_stage_tb();

reg feedback;
reg forward;
reg clk;
reg res_n;
wire out;

register_stage#(.with_xor(1)) register_stage_I(.feedback(feedback), .forward(forward), .clk(clk), .res_n(res_n), .out(out)); // should be a simple flipflop

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



















//// Testbench for the counter
//
//
//module counter_tb();
//
//	wire clock;
//	wire [7:0] count;
//	reg reset_n;
//	reg cnt_en;
//	reg cnt_clear;
//	
//	
//	clk_out clock_I(.clk(clock));
//
//	counter8 counter_I(
//			.clk(clock),
//			.res_n(reset_n),
//			.enable(cnt_en),
//			.clear(cnt_clear),
//			.cnt_out(count)
//			);
//	initial begin
//		reset_n <= 0;
//		//clock <= 1'b0;
//		cnt_en <= 1;
//		cnt_clear <= 0;
//		#100
//		reset_n = 1;
//	end
//endmodule
