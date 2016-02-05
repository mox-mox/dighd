`default_nettype none

module ram_tb;
parameter TESTWIDTH=16;
parameter TESTSIZE=10;

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


`include "log.v"
reg cs_a;
reg cs_b;
reg we_a;
reg we_b;
wire[TESTWIDTH-1:0] data_a;
wire[TESTWIDTH-1:0] data_b;
reg[TESTWIDTH-1:0] data_reg_a;
reg[TESTWIDTH-1:0] data_reg_b;
reg[log2(TESTSIZE)-1:0] addr_a;
reg[log2(TESTSIZE)-1:0] addr_b;

module ram #(.SIZE(), .WIDTH=16) (.clk(clk),
                                  .cs_a(cs_a), .we_a(we_a),
                                  .addr_a(addr_a), .data_a(data_a),
                                  .cs_b(cs_b), .we_b(we_b),
                                  .addr_b(addr_b), .data_b(data_b)
                                 );


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



	task check_fifo(input[TESTWIDTH-1:0] expected_data, input[TESTWIDTH-1:0] expected_data);
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


reg[TESTWIDTH-1:0] TESTVECTOR[TESTDEPTH*2+5:0];

integer write=-1;
integer read=0;
initial begin
	$dumpfile("fifo.vcd");
	$dumpvars(0, fifo_tb);
	//{{{
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

	shift_in  <= 1'b0;
	shift_out <= 1'b0;
	indata <= {TESTWIDTH{1'b0}};
	#half_clk_period
	res_n <= 1;


	$display("STARTING Shift_in TEST:");
	check_fifo(shift_out, outdata, full, empty, 16'hxxxx, 0, 1);





	$display("END");
	pass;
	$finish;
	end
endmodule
