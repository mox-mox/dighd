// Simple Moore State Machine implementing an Arbiter
module arbiter(input wire clk, input wire res_n,
               input wire[3:0] req,
               output wire[3:0] grant
              );

// State is encoded in 'state' using modified one-hot encoding.
reg[3:0] state;
parameter IDLE = 4'b0000;
parameter G0   = 4'b0001;
parameter G1   = 4'b0010;
parameter G2   = 4'b0100;
parameter G3   = 4'b1000;


// All state bits constitute to the output.
assign grant = state;


	always @(posedge clk or negedge res_n)
	begin
		if (res_n == 1'b0)
		begin // Go to idle state on reset.
			state <= IDLE;
		end
		else // posedge clk
		begin
			case(state)
				IDLE:
					casex(req)
						4'b0000: state <= IDLE;
						4'bxxx1: state <= G0;
						4'bxx10: state <= G1;
						4'bx100: state <= G2;
						4'b1000: state <= G3;
					endcase
				G0:
					casex(req)
						4'b0000: state <= IDLE;
						4'bxxx1: state <= G0;
						4'bxx10: state <= G1;
						4'bx100: state <= G2;
						4'b1000: state <= G3;
					endcase
				G1:
					casex(req)
						4'b0000: state <= IDLE;
						4'b0001: state <= G0;
						4'bxx1x: state <= G1;
						4'bx10x: state <= G2;
						4'b100x: state <= G3;
					endcase
				G2:
					casex(req)
						4'b0000: state <= IDLE;
						4'b00x1: state <= G0;
						4'b0010: state <= G1;
						4'bx1xx: state <= G2;
						4'b10xx: state <= G3;
					endcase
				G3:
					casex(req)
						4'b0000: state <= IDLE;
						4'b0xx1: state <= G0;
						4'b0x10: state <= G1;
						4'b0100: state <= G2;
						4'b1xxx: state <= G3;
					endcase
			endcase
		end
	end


	//{{{ Console output

	`ifdef VERBOSE
	integer j;
	always @(posedge clk)
	begin
		#1 $write("%c[1;34m%m: Requests:", 27);
		for (j = 3; j != -1; j = j - 1)
		begin
			if(req[j] == 1'b1)
				$write("■");
			else
				$write("◻");
		end
		$write("\n");
		$write("                      Grant(s):");
		for (j = 3; j != -1; j = j - 1)
		begin
			if(grant[j] == 1'b1)
				$write("^");
			else
				$write(" ");
		end
		$display("%c[0m", 27);
	end
	`endif
	//}}}

endmodule
