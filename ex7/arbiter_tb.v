`default_nettype none
//`timescale 1ns/1ns

module arbiter_tb;

	//{{{
	/* Make a regular pulsing clock. */
	parameter clk_period=10;
	parameter half_clk_period=5;
	reg clk = 1;
	always begin
		#half_clk_period
		//$display("clk \\");
		clk = 1'b0;

		#half_clk_period
		`ifdef SHOWCLOCK
			$display("clk /");
		`endif
		clk = 1'b1;
	end

	//{{{ Resynchronise the testbench to the clock

	task resync; // Used to phase-shift the testbench to align on the falling edge of the clock.
	begin        // They get out of phase, when crooked wait times are used, for example to generate an asyncronous reset.
		#(clk_period+half_clk_period-($time%clk_period));
	end
	endtask
	//}}}

	//}}}


	//{{{ Signals and module instantiation

	reg res_n = 0;

	reg[3:0] request;
	wire[3:0] grant;
	arbiter arbiter_I(.clk(clk), .res_n(res_n), .req(request), .grant(grant));
	//}}}


	//{{{ Messages, pretty printed

	task pass;
	begin
		$display("%c[1;32m",27);
		$display("***************************************");
		$display("*********** TEST CASE PASS ************");
		$display("***************************************");
		$write("%c[0m",27);
	end
	endtask

	task fail;
	begin
		$display("%c[1;31m",27);
		$display("***************************************");
		$display("*********** TEST CASE FAIL ************");
		$display("***************************************");
		$display("%c[0m",27);
		`ifdef FAILABORT
			$finish;
		`endif
	end
	endtask

	task success;
	begin
			$display("%c[1;32m-----------------------------------------------------------> SUCCESS.%c[0m\n", 27, 27);
	end
	endtask

	task defeat;
	begin
			$display("%c[1;31m-----------------------------------------------------------> FAILED.%c[0m\n", 27, 27);
			fail;
	end
	endtask
	//}}}


	//{{{ Check the module output

	task check_arbiter(input res_n, input[3:0] real_grant, input[3:0] expected_grant);
	begin
		//$display("Got output %h, expected_output %h", outdata, expected_outdata);
		if(res_n === 1'b1 && real_grant !== 4'b0000)
		begin
			$display("%c[1;31mArbiter TEST: Arbiter is not in idle state on reset.%c[0m", 27, 27);
			defeat;
		end
		if(expected_grant !== real_grant)
		begin
			$display("%c[1;31mArbiter TEST: Expected grant = %b but got %b.%c[0m", 27, expected_grant, real_grant, 27);
			defeat;
		end
	end
	endtask
	//}}}


	//{{{ Parameters and Variables for testing

	parameter TESTSTEPS=10;
	reg[3:0] expected_grant=4'b0000;
	//}}}



	initial begin
	//{{{ Dump the waveform to file for reading with gtkwave.

	`ifdef DUMP_DATA
		$dumpfile("arbiter.vcd");
		$dumpvars(0, arbiter_tb);
	`endif
	//}}}

	//{{{ Initialise the signals, release reset

	request <= 4'b0000;
	#half_clk_period
	res_n <= 1;
	//}}}


	$display("STARTING Idle TEST:");
	check_arbiter(res_n, grant, expected_grant);

	repeat(TESTSTEPS)
	begin
		request <= 4'b0000; expected_grant <= 4'b0000;
		#clk_period;
		check_arbiter(res_n, grant, expected_grant);
	end
	success;



	pass;
	$finish;
	end
endmodule
		//$write(" ◻◼▯■□●◯◾◾◽ Address = %g",j);
