		//$write(" ◻◼▯■□●◯◾◾◽ Address = %g",j);
`default_nettype none
//`timescale 1ns/1ns

module fifo_tb;
parameter TESTWIDTH=16;
parameter TESTDEPTH=10;
	//{{{
	/* Make a regular pulsing clock. */
	parameter clk_period=10;
	parameter half_clk_period=5;
	//parameter half_clk_period=clk_period*0.5;
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
	//}}}

	task resync; // Used to phase-shift the testbench to align on the falling edge of the clock.
	begin        // They get out of phase, when crooked wait times are used, for example to generate an asyncronous reset.
		#(clk_period+half_clk_period-($time%clk_period));
	end
	endtask



	/* Make a reset that pulses once. */
	reg res_n = 0;

	reg[TESTWIDTH-1:0] indata={TESTWIDTH{1'b0}};
	wire[TESTWIDTH-1:0] outdata;
	reg shift_in;
	reg shift_out;
	wire full;
	wire empty;

	fifo #(.WIDTH(TESTWIDTH), .DEPTH(TESTDEPTH)) fifo_I(.clk(clk), .res_n(res_n),
	                                            .wdata(indata), .rdata(outdata),
	                                            .shift_in(shift_in), .shift_out(shift_out),
	                                            .full(full), .empty(empty)
	                                           );

//	task print_status(input[TESTWIDTH-1:0] outdata, input full, input empty);
//	begin
//		if(full == 1'b0 && empty == 1'b0)
//			$display("%t: output=%h",$time, outdata);
//		if(full == 1'b0 && empty == 1'b1)
//			$display("%t: output=%h EMPTY",$time, outdata);
//		if(full == 1'b1 && empty == 1'b0)
//			$display("%t: output=%h FULL",$time, outdata);
//		if(full == 1'b1 && empty == 1'b1)
//			$display("%t: output=%h FULL EMPTY",$time, outdata);
//	end
//	endtask
//	always @(outdata, full, empty) begin
//		print_status(outdata, full, empty);
//	end



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



	task check_fifo(input shift_out, input[TESTWIDTH-1:0] outdata, input full, input empty, input[TESTWIDTH-1:0] expected_outdata, input expected_full, input expected_empty);
	begin
		if(full === 1'b1 && empty === 1'b1)
		begin
			$display("%c[1;31mFIFO TEST: EMPTY and FULL at the same time.%c[0m", 27, 27);
			defeat;
		end
		if(full !== expected_full)
		begin
			$display("%c[1;31mFIFO TEST: Expected full = %b but got %b.%c[0m", 27, expected_full, full, 27);
			defeat;
		end
		if(empty !== expected_empty)
		begin
			$display("%c[1;31mFIFO TEST: Expected empty = %b but got %b.%c[0m", 27, expected_empty, empty, 27);
			defeat;
		end
		if(^expected_outdata!==1'bX && expected_empty == 1'b0 && shift_out == 1'b1 && outdata !== expected_outdata)
		begin
			$display("%c[1;31mFIFO TEST: Expected output = %h but got %h.%c[0m", 27, expected_outdata, outdata, 27);
			defeat;
		end
	end
	endtask







// Jeweils alle Kombinationen von shift_in, shift_out und reset für die Füllstände "Leer" "Ein Element" "Halbvoll" "Fast voll" und "Voll".
// Für echte Hardware zusätzlich noch Test, ob der Fifo bei bestimmten Daten Probleme bekommt (Siehe FDIV-Bug).


reg[TESTWIDTH-1:0] TESTVECTOR[TESTDEPTH*2+5:0];

integer write=-1;
integer read=0;
	initial begin
	$dumpfile("fifo.vcd");
	$dumpvars(0, fifo_tb);
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

	shift_in  <= 1'b0;
	shift_out <= 1'b0;
	indata <= {TESTWIDTH{1'b0}};
	#half_clk_period
	res_n <= 1;

	$display("STARTING Shift_in TEST:");
	check_fifo(shift_out, outdata, full, empty, 16'hxxxx, 0, 1);

	repeat(TESTDEPTH-1)
	begin
		shift_in <= 1; write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 0;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
	end
	shift_in <= 1; write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 0;// read++;
	#clk_period;
	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
	success;

	$display("STARTING FULL NOP TEST:");
	repeat(5)
	begin
		shift_in <= 0; //write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 0;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
	end
	success;

	$display("STARTING Shift_out TEST:");
	repeat(TESTDEPTH-1)
	begin
		shift_in <= 0; //write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 1; read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
	end
	shift_in <= 0; //write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 1; read++;
	#clk_period;
	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 1);
	success;

	$display("STARTING EMPTY NOP TEST:");
	repeat(5)
	begin
		shift_in <= 0; //write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 0;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, 16'hxxxx, 0, 1);
	end
	success;

	$display("STARTING UNDERFILL TEST:");
	// FIFO is empty now
	`ifdef DEBUG
		$display("%c[1;33mThere should be 5 debug message here, each saying that invalid data from an empty FIFO is returned.%c[0m", 27, 27);
	`endif
	repeat(5)
	begin
		shift_in <= 0; //write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 1;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, {TESTWIDTH{1'bx}}, 0, 1); // Only check that the FIFO stays empty
	end
	success;

	$display("STARTING OVERFILL TEST:");
	write=-1;
	read=0;
	check_fifo(shift_out, outdata, full, empty, {TESTWIDTH{1'bx}}, 0, 1);

	repeat(TESTDEPTH-1)
	begin
		shift_in <= 1; write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 0;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
	end
	shift_in <= 1; write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 0;// read++;
	#clk_period;
	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);

	// FIFO is full now

	`ifdef DEBUG
		$display("%c[1;33mThere should be 5 debug message here, each saying that a data member was dropped.%c[0m", 27, 27);
	`endif
	repeat(5)
	begin
		shift_in <= 1; //write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 0;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
	end

	repeat(TESTDEPTH-1)
	begin
		shift_in <= 0; //write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 1; read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
	end
	shift_in <= 0; //write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 1; read++;
	#clk_period;
	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 1);
	success;

	$display("STARTING EMPTY PASS-THROUGH TEST");
	shift_in <= 0;
	shift_out <= 0;
	#2 res_n = 0; // Generate a short (asynchronous) spike on the reset line
	$display("-- reset --");
	#1 res_n = 1;
	resync;
	write=-1;
	read=-1;

	shift_in <= 1; write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 1; read++;
	#clk_period;
	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
	shift_in <= 0; //write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 0; //read++;
	#clk_period;














	$display("STARTING EMPTY RESET TEST:");

	check_fifo(shift_out, outdata, full, empty, {TESTWIDTH{1'b0}}, 0, 1);
	shift_in <= 0; //write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 0; //read++;
	#clk_period;

	#2 res_n = 0; // Generate a short (asynchronous) spike on the reset line
	$display("-- reset --");
	#1 res_n = 1;
	resync;

	check_fifo(shift_out, outdata, full, empty, {TESTWIDTH{1'b0}}, 0, 1);
	success;

	$display("STARTING SEMI-FULL RESET TEST:");
	write=0; // Restart the test pattern
	read=0;
	check_fifo(shift_out, outdata, full, empty, 16'hxxxx, 0, 1);

	repeat(TESTDEPTH-5)
	begin
		shift_in <= 1; write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 0;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
	end
	shift_in <= 0; //write++;

	#3 res_n = 0; // Generate a short (asynchronous) spike on the reset line
	$display("-- reset --");
	#1 res_n = 1;
	resync;

	check_fifo(shift_out, outdata, full, empty, {TESTWIDTH{1'b0}}, 0, 1);
	success;

	$display("STARTING FULL RESET TEST:");
	write=0; // Restart the test pattern
	read=0;
	check_fifo(shift_out, outdata, full, empty, 16'hxxxx, 0, 1);

	repeat(TESTDEPTH-1)
	begin
		shift_in <= 1; write++;
		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
		shift_out <= 0;// read++;
		#clk_period;
		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
	end
	shift_in <= 1; write++;
	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
	shift_out <= 0;// read++;
	#clk_period;
	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
	shift_in <= 0; //write++;

	#3 res_n = 0; // Generate a short (asynchronous) spike on the reset line
	$display("-- reset --");
	#1 res_n = 1;
	resync;

	check_fifo(shift_out, outdata, full, empty, {TESTWIDTH{1'b0}}, 0, 1);
	success;










	$display("END");
	pass;
	$finish;




//	shift_in <= 1; write++;
//	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
//	shift_out <= 0;// read++;
//	#clk_period;
//	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
//
//	// NOP to see the full state shown
//	shift_in <= 0; //write++;
//	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
//	shift_out <= 0;// read++;
//	#clk_period;
//	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
//	success;
//
//
//	write=-1; // Restart the test pattern
//	read=0;
//
//	#2 res_n = 0; // Generate a short (asynchronous) spike on the reset line
//	#1 res_n = 1;
//
//
//
//
//
//
//	$display("STARTING FULL RESET TEST:");
//	check_fifo(shift_out, outdata, full, empty, 16'hxxxx, 0, 1);
//
//	repeat(TESTDEPTH-1)
//	begin
//		shift_in <= 1; write++;
//		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
//		shift_out <= 0;// read++;
//		#clk_period;
//		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 0, 0);
//	end
//	shift_in <= 1; write++;
//	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
//	shift_out <= 0;// read++;
//	#clk_period;
//	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
//
//	// NOP to see the full state shown
//	shift_in <= 0; //write++;
//	indata <= TESTVECTOR[write][TESTWIDTH-1:0];
//	shift_out <= 0;// read++;
//	#clk_period;
//	check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
//	success;
//
//	$display("STARTING FULL NOP TEST:");
//	repeat(5)
//	begin
//		shift_in <= 0; //write++;
//		indata <= TESTVECTOR[write][TESTWIDTH-1:0];
//		shift_out <= 0;// read++;
//		#clk_period;
//		check_fifo(shift_out, outdata, full, empty, TESTVECTOR[read][TESTWIDTH-1:0], 1, 0);
//	end
//
//	#2 res_n = 0; // Generate a short (asynchronous) spike on the reset line
//	#1 res_n = 1;
//	check_fifo(shift_out, outdata, full, empty, {TESTWIDTH{1'b0}}, 0, 1);
//	success;




	// TODO:
	// - Reset-test for semi-full
	// - Reset-test for full
	// - Reset-operation-test for empty
	// - Reset-operation-test for semi-full
	// - Reset-operation-test for full
	// - Pass-through-test for empty state
	// - Pass-through-test for semi-full





	//#10
	$finish;
	end







	//initial $monitor("%t: output: %h (%0d)", $time, outdata, value);



endmodule
