module register_stage#(parameter with_xor=0)(input wire clk, input wire res_n, input wire clear, input wire enable,  input wire forward, input wire feedback, output wire out);

reg data;
assign out = with_xor? (data^feedback):(data);

always @(posedge clk or negedge res_n)
begin
	if(res_n == 1'b0 || clear == 1'b1)
		data <= 1'b1;
	else if(enable == 1'b1)
		data <= forward;
end


endmodule
