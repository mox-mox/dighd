module register_stage#(parameter with_xor=0)(input wire clk, input wire res_n, input wire forward, input wire feedback, output wire out);

reg data;
assign out = with_xor? (data^feedback):(data);

always @(posedge clk or negedge res_n)
begin
	if(res_n == 1'b0)
		data <= 1'b1;
	else
		data <= forward;
end


endmodule
