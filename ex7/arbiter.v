module arbiter(input wire clk, input wire res_n,
               input wire[3:0] req,
               output reg[3:0] grant
              )



// Simple Moore State Machine
// States |  Encoded as
// -------+------------
// Idle   | grant[3:0] = 4'b0000
// G0     | grant[3:0] = 4'b0001
// G1     | grant[3:0] = 4'b0010
// G2     | grant[3:0] = 4'b0100
// G3     | grant[3:0] = 4'b1000



	always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin
			data_out <= {WIDTH{1'b0}};
			filled <= 1'b0;
		end
		else // posedge clk
		begin
			case
		end
	end


endmodule
