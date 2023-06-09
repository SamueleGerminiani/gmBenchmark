`timescale 1ns/1ps

module ibex_compressed_decoder_bench();

reg clk;
reg DEFAULT_RESET;
reg [31:0] instr_i;

wire is_compressed_o;
wire [31:0] instr_o;
wire illegal_instr_o;

ibex_compressed_decoder ibex_compressed_decoder_ (
	.instr_i(instr_i),
	.is_compressed_o(is_compressed_o),
	.instr_o(instr_o),
	.illegal_instr_o(illegal_instr_o),
    .clk(clk)
);

	initial begin
//		$dumpfile("/home/sam/goldminer/RunTime/goldmine.out/ibex_compressed_decoder/ibex_compressed_decoder.vcd");
//		$dumpvars(0, ibex_compressed_decoder_bench);
		clk = 1;
		DEFAULT_RESET = 1;
		#26;
		DEFAULT_RESET = 0;
		#50000 $finish;
	end

	always begin
		#25 clk = ~clk;
	end

	always begin
		#24;
		instr_i = $random;
		#26;
	end

endmodule
