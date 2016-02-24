		//$write(" ◻◼▯■□●◯◾◾◽ Address = %g",j);
`default_nettype none
//`timescale 1ns/1ns

module ser_64_16_tb;
parameter INWIDTH=64;
parameter OUTWIDTH=16;
parameter DEPTH = INWIDTH/OUTWIDTH;

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

	reg[INWIDTH-1:0] indata={INWIDTH{1'b0}};
	wire[OUTWIDTH-1:0] outdata;
	reg valid_in;
	reg stop_in;
	wire stop_out;
	wire valid_out;

	ser_64_16 #(.INWIDTH(INWIDTH), .OUTWIDTH(OUTWIDTH)) ser_64_16_I(.clk(clk), .res_n(res_n),
	                                                                .wdata(indata), .rdata(outdata),
	                                                                .valid_in(valid_in), .valid_out(valid_out),
	                                                                .stop_out(stop_out), .stop_in(stop_in)
	                                                               );
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

	task check_ser_64_16(input[OUTWIDTH-1:0] outdata, input[OUTWIDTH-1:0] expected_outdata, input stop_out, input expected_stop_out, input valid_out, input expected_valid_out);
	begin
		if(valid_out !== expected_valid_out)
		begin
			$display("%c[1;31mFIFO TEST: Expected valid_out = %b but got %b.%c[0m", 27, expected_valid_out, valid_out, 27);
			defeat;
		end
		if(stop_out !== expected_stop_out)
		begin
			$display("%c[1;31mFIFO TEST: Expected stop_out = %b but got %b.%c[0m", 27, expected_stop_out, stop_out, 27);
			defeat;
		end
		if(^expected_outdata!==1'bX && expected_valid_out == 1'b0 && outdata !== expected_outdata)
		begin
			$display("%c[1;31mFIFO TEST: Expected output = %h but got %h.%c[0m", 27, expected_outdata, outdata, 27);
			defeat;
		end
	end
	endtask
	//}}}


	//{{{ Parameters and Variables for testing

	parameter VL=26;
reg[OUTWIDTH-1:0] TESTVECTOR[VL-1:0];

	//}}}

integer write=0;
integer read=0;
	initial begin
	//{{{ Dump the waveform to file for reading with gtkwave.

	`ifdef DUMP_DATA
		$dumpfile("ser_64_16.vcd");
		$dumpvars(0, ser_64_16_tb);
	`endif
	//}}}

	//{{{ Initialise TESTVECTOR

	TESTVECTOR[ 0] = 16'haffe;
	TESTVECTOR[ 1] = 16'hcafe;
	TESTVECTOR[ 2] = 16'hbabe;
	TESTVECTOR[ 3] = 16'hb00b;
	TESTVECTOR[ 4] = 16'hc001;
	TESTVECTOR[ 5] = 16'hf00d;
	TESTVECTOR[ 6] = 16'hdead;
	TESTVECTOR[ 7] = 16'hbeef;
	TESTVECTOR[ 8] = 16'hc0de;
	TESTVECTOR[ 9] = 16'hfa11;
	TESTVECTOR[10] = 16'hface;
	TESTVECTOR[11] = 16'hfee1;
	TESTVECTOR[12] = 16'h0123;
	TESTVECTOR[13] = 16'h4567;
	TESTVECTOR[14] = 16'h89ab;
	TESTVECTOR[15] = 16'hcdef;
	TESTVECTOR[16] = 16'h1111;
	TESTVECTOR[17] = 16'h2222;
	TESTVECTOR[18] = 16'h3333;
	TESTVECTOR[19] = 16'h4444;
	TESTVECTOR[20] = 16'h5555;
	TESTVECTOR[21] = 16'h6666;
	TESTVECTOR[22] = 16'h7777;
	TESTVECTOR[23] = 16'h8888;
	TESTVECTOR[24] = 16'h9999;
	TESTVECTOR[25] = 16'ha5a5;
	//}}}

	valid_in  <= 1'b0;
	stop_in <= 1'b0;
	indata <= {INWIDTH{1'b0}};
	#half_clk_period
	res_n <= 1;


	$display("STARTING Fill And Drain TEST:");
	check_ser_64_16(outdata, {OUTWIDTH{1'bx}}, stop_out, 0, valid_out, 0);

	valid_in <= 1; write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 0, valid_out, 1);

	$display("");

	valid_in <= 1; write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 0, valid_out, 1);
	success;


	$display("STARTING Fill And Drain with STOPs TEST:");
	//check_ser_64_16(outdata, {OUTWIDTH{1'bx}}, stop_out, 0, valid_out, 0);
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 0, valid_out, 1);

	$display("/stop");
	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 0, valid_out, 0);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 0, valid_out, 0);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 0);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 0);

	$display("\\stop");

	valid_in <= 1; write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);


	$display("/stop");
	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);
	$display("\\stop");


	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	$display("/stop");
	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);
	$display("\\stop");

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	$display("/stop");
	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);
	$display("\\stop");

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 0, valid_out, 1);

	$display("");

	valid_in <= 1; write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	$display("/stop");
	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);

	valid_in <= 1; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 1; //read++;
	#clk_period;
	check_ser_64_16(outdata, {OUTWIDTH{1'b1}}, stop_out, 1, valid_out, 1);
	$display("\\stop");

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 1, valid_out, 1);

	valid_in <= 0; //write <= write+4;
	indata <= {TESTVECTOR[(write+0)%VL], TESTVECTOR[(write+1)%VL], TESTVECTOR[(write+2)%VL], TESTVECTOR[(write+3)%VL]};
	stop_in <= 0; read++;
	#clk_period;
	check_ser_64_16(outdata, TESTVECTOR[read%VL], stop_out, 0, valid_out, 1);
	success;









	$display("END");
	pass;
	$finish;
	end
endmodule
