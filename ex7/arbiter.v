// Simple Moore State Machine implementing an Arbiter
module arbiter(input wire clk, input wire res_n,
               input wire[3:0] req,
               output wire[3:0] grant
              );

// State is encoded in 'state' using modified one-hot encoding.
reg[3:0] state;
`define ARBITER_IDLE 4'b0000
`define ARBITER_G0   4'b0001
`define ARBITER_G1   4'b0010
`define ARBITER_G2   4'b0100
`define ARBITER_G3   4'b1000


// All state bits constitute to the output.
assign grant = state;


	always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin // Go to idle state on reset.
			state <= ARBITER_IDLE;
		end
		else // posedge clk
		begin
			case(state)
				ARBITER_IDLE:
					casex(req)
						4'b0000: state <= ARBITER_IDLE;
						4'b1xxx: state <= ARBITER_G0;
						4'b01xx: state <= ARBITER_G1;
						4'b001x: state <= ARBITER_G2;
						4'b0001: state <= ARBITER_G3;
					endcase
				ARBITER_G0:
					casex(req)
						4'b0000: state <= ARBITER_IDLE;
						4'b1xxx: state <= ARBITER_G0;
						4'b01xx: state <= ARBITER_G1;
						4'b001x: state <= ARBITER_G2;
						4'b0001: state <= ARBITER_G3;
					endcase
				ARBITER_G1:
					casex(req)
						4'b0000: state <= ARBITER_IDLE;
						4'b1000: state <= ARBITER_G0;
						4'bx1xx: state <= ARBITER_G1;
						4'bx01x: state <= ARBITER_G2;
						4'bx001: state <= ARBITER_G3;
					endcase
				ARBITER_G2:
					casex(req)
						4'b0000: state <= ARBITER_IDLE;
						4'b1x00: state <= ARBITER_G0;
						4'b0100: state <= ARBITER_G1;
						4'bxx1x: state <= ARBITER_G2;
						4'bxx01: state <= ARBITER_G3;
					endcase
				ARBITER_G3:
					casex(req)
						4'b0000: state <= ARBITER_IDLE;
						4'b1xx0: state <= ARBITER_G0;
						4'b01x0: state <= ARBITER_G1;
						4'b0010: state <= ARBITER_G2;
						4'bxxx1: state <= ARBITER_G3;
					endcase
			endcase
		end
	end
// Avoid polluting the global namespace
`undef ARBITER_IDLE
`undef ARBITER_G0
`undef ARBITER_G1
`undef ARBITER_G2
`undef ARBITER_G3
endmodule
