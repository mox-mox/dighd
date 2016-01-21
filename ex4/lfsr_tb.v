// Testbench for the counter


module lfsr_tb();

	parameter TESTSTEPS = 100;
	parameter COUNTERWIDTH = 32; // Must be at least log2(TESTSTEPS)

	wire clock;
	wire shifter_data;
	reg reset_n;
	reg cnt_en;
	reg shift_en;
	reg cnt_clear;
	wire [COUNTERWIDTH-1:0] simulation_step;
	reg one;


	// Generated from c++ file in same folder.
	// Test vector for the long test.
	reg[TESTSTEPS-1:0] shifter_nominal_output = 100'b1000101100000000101001011000111000001010011000100001101001001001000001000001100000001001000000000001;

	// Test vector for the 10-bit example
	//reg[TESTSTEPS-1:0] shifter_nominal_output = 101'b0000100001000000000100001000000000100001000000000100001000000000100001000000000100001000000000100001;
	reg shifter_nominal;

	clk_out clock_I(.clk(clock));

	counter #(.width(COUNTERWIDTH)) counter_I(
			                       .clk(clock),
			                       .res_n(reset_n),
			                       .enable(cnt_en),
			                       .clear(cnt_clear),
			                       .cnt_out(simulation_step)
			                      );
	//lfsr #(.width(57), .polynomial(57'b000000000010000000000000000000000100000001001000000000000)) lfsr_I(
	lfsr #(.width(57), .polynomial(57'b0000000000001001000000010000000000000000000000100000000000)) lfsr_I(
	//lfsr #(.width(10), .polynomial(10'b0000100000)) lfsr_I( // 10-bit example
	                                                     .clk(clock),
	                                                     .res_n(reset_n),
	                                                     .enable(shift_en),
	                                                     .clear(cnt_clear),
	                                                     .d_out(shifter_data)
	                                                    );

	initial begin
		reset_n   <= 0;
		cnt_clear <= 0;
		cnt_en    <= 0;
		shift_en  <= 0;
		#10
		$display("Starting Simulation");
		reset_n   <= 1;
		shift_en  <= 1;
		#10
		cnt_en    <= 1;

		#1000 $stop;
	end

	always @(posedge clock)
	begin
		shifter_nominal = shifter_nominal_output[simulation_step]; // Yes, the blocking assingment is intended here.
		one = !shifter_data^shifter_nominal;                      // And here, too.
		$display ("Time: %3d, Soll: %b, Ist: %b, One: %b", simulation_step[31:0], shifter_nominal, shifter_data, one);

		//assert(one);
	end


endmodule
