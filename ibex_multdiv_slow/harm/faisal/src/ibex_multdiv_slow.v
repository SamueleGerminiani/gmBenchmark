`include "faisal.v"
module ibex_multdiv_slow (
	clk_i,
	rst_ni,
	mult_en_i,
	div_en_i,
	operator_i,
	signed_mode_i,
	op_a_i,
	op_b_i,
	alu_adder_ext_i,
	alu_adder_i,
	equal_to_zero,
	alu_operand_a_o,
	alu_operand_b_o,
	multdiv_result_o,
	valid_o
);
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj1, 1)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj2, 2)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj3, 3)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj4, 4)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj5, 5)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj6, 6)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj7, 6)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj8, 6)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj12, 6)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj16, 16)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj31, 31)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj32, 32)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj33, 33)
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj34, 34)

	localparam [2:0] MD_IDLE = 0;
	localparam [2:0] MD_ABS_A = 1;
	localparam [2:0] MD_ABS_B = 2;
	localparam [2:0] MD_COMP = 3;
	localparam [2:0] MD_LAST = 4;
	localparam [2:0] MD_CHANGE_SIGN = 5;
	localparam [2:0] MD_FINISH = 6;
	input wire clk_i;
	input wire rst_ni;
	input wire mult_en_i;
	input wire div_en_i;
	input wire [1:0] operator_i;
	input wire [1:0] signed_mode_i;
	input wire [31:0] op_a_i;
	input wire [31:0] op_b_i;
	input wire [33:0] alu_adder_ext_i;
	input wire [31:0] alu_adder_i;
	input wire equal_to_zero;
	output reg [32:0] alu_operand_a_o;
	output reg [32:0] alu_operand_b_o;
	output reg [31:0] multdiv_result_o;
	output wire valid_o;
	`include "ibex_pkg.v"
	reg [4:0] multdiv_state_q;
	reg [4:0] multdiv_state_d;
	wire [4:0] multdiv_state_m1;
	reg [2:0] md_state_q;
	reg [2:0] md_state_d;
	reg [32:0] accum_window_q;
	reg [32:0] accum_window_d;
	wire [32:0] res_adder_l;
	wire [32:0] res_adder_h;
	reg [32:0] op_b_shift_q;
	reg [32:0] op_b_shift_d;
	reg [32:0] op_a_shift_q;
	reg [32:0] op_a_shift_d;
	wire [32:0] op_a_ext;
	wire [32:0] op_b_ext;
	wire [32:0] one_shift;
	wire [32:0] op_a_bw_pp;
	wire [32:0] op_a_bw_last_pp;
	wire [31:0] b_0;
	wire sign_a;
	wire sign_b;
	wire [32:0] next_reminder;
	wire [32:0] next_quotient;
	wire [32:0] op_remainder;
	reg [31:0] op_numerator_q;
	reg [31:0] op_numerator_d;
	wire is_greater_equal;
	wire div_change_sign;
	wire rem_change_sign;
	assign res_adder_l = fault_inj33(alu_adder_ext_i[32:0],1,33);
	assign res_adder_h = fault_inj33(alu_adder_ext_i[33:1],34,66);
	always @(*) begin
		alu_operand_a_o = fault_inj33(accum_window_q,67,99);
		multdiv_result_o = (fault_inj1(div_en_i,100,100) ? fault_inj32(accum_window_q[31:0],101,132) : fault_inj33(res_adder_l,133,165));
		case (fault_inj2(operator_i,166,167))
			MD_OP_MULL: alu_operand_b_o = fault_inj33(op_a_bw_pp,168,200);
			MD_OP_MULH: alu_operand_b_o = ((fault_inj3(md_state_q,201,203) == fault_inj3(MD_LAST,204,206)) ? fault_inj33(op_a_bw_last_pp,207,239) : fault_inj33(op_a_bw_pp,240,272));
			default: case (fault_inj3(md_state_q,273,275))
			MD_IDLE: begin
				alu_operand_a_o = {fault_inj32(32'h0,276,307), fault_inj1(1'b1,308,308)};
				alu_operand_b_o = {~fault_inj32(op_b_i,309,340), fault_inj1(1'b1,341,341)};
			end
			MD_ABS_A: begin
				alu_operand_a_o = {fault_inj32(32'h0,342,373), fault_inj1(1'b1,374,374)};
				alu_operand_b_o = {~fault_inj32(op_a_i,375,406), fault_inj1(1'b1,407,407)};
			end
			MD_ABS_B: begin
				alu_operand_a_o = {fault_inj32(32'h0,408,439), fault_inj1(1'b1,440,440)};
				alu_operand_b_o = {~fault_inj32(op_b_i,441,472), fault_inj1(1'b1,473,473)};
			end
			MD_CHANGE_SIGN: begin
				alu_operand_a_o = {fault_inj32(32'h0,474,505), fault_inj1(1'b1,506,506)};
				alu_operand_b_o = {~fault_inj32(accum_window_q[31:0],507,538), fault_inj1(1'b1,539,539)};
			end
			default: begin
			alu_operand_a_o = {fault_inj32(accum_window_q[31:0],540,571), fault_inj1(1'b1,572,572)};
			alu_operand_b_o = {~fault_inj32(op_b_shift_q[31:0],573,604), fault_inj1(1'b1,605,605)};
		end
		endcase
		endcase
	end
	assign is_greater_equal = (((fault_inj1(accum_window_q[31],606,606) ^ fault_inj1(op_b_shift_q[31],607,607)) == fault_inj1(1'b0,608,608)) ? (fault_inj1(res_adder_h[31],609,609) == fault_inj1(1'b0,610,610)) : fault_inj1(accum_window_q[31],611,611));
	assign one_shift = ({fault_inj32(32'b0,612,643), fault_inj1(1'b1,644,644)} << fault_inj5(multdiv_state_q,645,649));
	assign next_reminder = (fault_inj1(is_greater_equal,650,650) ? fault_inj33(res_adder_h,651,683) : fault_inj33(op_remainder,684,716));
	assign next_quotient = (fault_inj1(is_greater_equal,717,717) ? (fault_inj33(op_a_shift_q,718,750) | fault_inj33(one_shift,751,783)) : fault_inj33(op_a_shift_q,784,816));
	assign b_0 = {32 {fault_inj1(op_b_shift_q[0],817,817)}};
	assign op_a_bw_pp = {~(fault_inj1(op_a_shift_q[32],818,818) & fault_inj1(op_b_shift_q[0],819,819)), (fault_inj32(op_a_shift_q[31:0],820,851) & fault_inj32(b_0,852,883))};
	assign op_a_bw_last_pp = {(fault_inj1(op_a_shift_q[32],884,884) & fault_inj1(op_b_shift_q[0],885,885)), ~(fault_inj32(op_a_shift_q[31:0],886,917) & fault_inj32(b_0,918,949))};
	assign sign_a = (fault_inj1(op_a_i[31],950,950) & fault_inj1(signed_mode_i[0],951,951));
	assign sign_b = (fault_inj1(op_b_i[31],952,952) & fault_inj1(signed_mode_i[1],953,953));
	assign op_a_ext = {fault_inj1(sign_a,954,954), fault_inj32(op_a_i,955,986)};
	assign op_b_ext = {fault_inj1(sign_b,987,987), fault_inj32(op_b_i,988,1019)};
	assign op_remainder = fault_inj33(accum_window_q[32:0],1020,1052);
	assign multdiv_state_m1 = (fault_inj5(multdiv_state_q,1053,1057) - fault_inj5(5'h1,1058,1062));
	assign div_change_sign = (fault_inj1(sign_a,1063,1063) ^ fault_inj1(sign_b,1064,1064));
	assign rem_change_sign = fault_inj1(sign_a,1065,1065);
	always @(posedge clk_i or negedge rst_ni) begin : proc_multdiv_state_q
		if (!fault_inj1(rst_ni,1066,1066)) begin
			multdiv_state_q <= fault_inj5(5'h0,1067,1071);
			accum_window_q <= fault_inj33(33'h0,1072,1104);
			op_b_shift_q <= fault_inj33(33'h0,1105,1137);
			op_a_shift_q <= fault_inj33(33'h0,1138,1170);
			op_numerator_q <= fault_inj32(32'h0,1171,1202);
			md_state_q <= fault_inj3(MD_IDLE,1203,1205);
		end
		else begin
			multdiv_state_q <= fault_inj5(multdiv_state_d,1206,1210);
			accum_window_q <= fault_inj33(accum_window_d,1211,1243);
			op_b_shift_q <= fault_inj33(op_b_shift_d,1244,1276);
			op_a_shift_q <= fault_inj33(op_a_shift_d,1277,1309);
			op_numerator_q <= fault_inj32(op_numerator_d,1310,1341);
			md_state_q <= fault_inj3(md_state_d,1342,1344);
		end
	end
	always @(*) begin
		multdiv_state_d = fault_inj5(multdiv_state_q,1345,1349);
		accum_window_d = fault_inj33(accum_window_q,1350,1382);
		op_b_shift_d = fault_inj33(op_b_shift_q,1383,1415);
		op_a_shift_d = fault_inj33(op_a_shift_q,1416,1448);
		op_numerator_d = fault_inj32(op_numerator_q,1449,1480);
		md_state_d = fault_inj3(md_state_q,1481,1483);
		if ((fault_inj1(mult_en_i,1484,1484) || fault_inj1(div_en_i,1485,1485)))
			case (fault_inj3(md_state_q,1486,1488))
				MD_IDLE: begin
					case (fault_inj2(operator_i,1489,1490))
						MD_OP_MULL: begin
							op_a_shift_d = (fault_inj33(op_a_ext,1491,1523) << 1);
							accum_window_d = {~(fault_inj1(op_a_ext[32],1524,1524) & fault_inj1(op_b_i[0],1525,1525)), (fault_inj32(op_a_ext[31:0],1526,1557) & {32 {fault_inj1(op_b_i[0],1558,1558)}})};
							op_b_shift_d = (fault_inj33(op_b_ext,1559,1591) >> 1);
							md_state_d = fault_inj3(MD_COMP,1592,1594);
						end
						MD_OP_MULH: begin
							op_a_shift_d = fault_inj33(op_a_ext,1595,1627);
							accum_window_d = {fault_inj1(1'b1,1628,1628), ~(fault_inj1(op_a_ext[32],1629,1629) & fault_inj1(op_b_i[0],1630,1630)), (fault_inj31(op_a_ext[31:1],1631,1661) & {31 {fault_inj1(op_b_i[0],1662,1662)}})};
							op_b_shift_d = (fault_inj33(op_b_ext,1663,1695) >> 1);
							md_state_d = fault_inj3(MD_COMP,1696,1698);
						end
						MD_OP_DIV: begin
							accum_window_d = {33 {fault_inj1(1'b1,1699,1699)}};
							md_state_d = (fault_inj1(equal_to_zero,1700,1700) ? fault_inj3(MD_FINISH,1701,1703) : fault_inj3(MD_ABS_A,1704,1706));
						end
						default: begin
						accum_window_d = fault_inj33(op_a_ext,1707,1739);
						md_state_d = (fault_inj1(equal_to_zero,1740,1740) ? fault_inj3(MD_FINISH,1741,1743) : fault_inj3(MD_ABS_A,1744,1746));
					end
					endcase
					multdiv_state_d = fault_inj5(5'd31,1747,1751);
				end
				MD_ABS_A: begin
					op_a_shift_d = fault_inj1(1'sb0,1752,1752);
					op_numerator_d = (fault_inj1(sign_a,1753,1753) ? fault_inj32(alu_adder_i,1754,1785) : fault_inj32(op_a_i,1786,1817));
					md_state_d = fault_inj3(MD_ABS_B,1818,1820);
				end
				MD_ABS_B: begin
					accum_window_d = {fault_inj32(32'h0,1821,1852), fault_inj1(op_numerator_q[31],1853,1853)};
					op_b_shift_d = (fault_inj1(sign_b,1854,1854) ? fault_inj32(alu_adder_i,1855,1886) : fault_inj32(op_b_i,1887,1918));
					md_state_d = fault_inj3(MD_COMP,1919,1921);
				end
				MD_COMP: begin
					multdiv_state_d = fault_inj5(multdiv_state_m1,1922,1926);
					case (fault_inj2(operator_i,1927,1928))
						MD_OP_MULL: begin
							accum_window_d = fault_inj33(res_adder_l,1929,1961);
							op_a_shift_d = (fault_inj33(op_a_shift_q,1962,1994) << 1);
							op_b_shift_d = (fault_inj33(op_b_shift_q,1995,2027) >> 1);
						end
						MD_OP_MULH: begin
							accum_window_d = fault_inj33(res_adder_h,2028,2060);
							op_a_shift_d = fault_inj33(op_a_shift_q,2061,2093);
							op_b_shift_d = (fault_inj33(op_b_shift_q,2094,2126) >> 1);
						end
						default: begin
						accum_window_d = {fault_inj32(next_reminder[31:0],2127,2158), fault_inj1(op_numerator_q[multdiv_state_m1],2159,2159)};
						op_a_shift_d = fault_inj33(next_quotient,2160,2192);
					end
					endcase
					md_state_d = ((fault_inj5(multdiv_state_q,2193,2197) == fault_inj5(5'd1,2198,2202)) ? fault_inj3(MD_LAST,2203,2205) : fault_inj3(MD_COMP,2206,2208));
				end
				MD_LAST:
					case (fault_inj2(operator_i,2209,2210))
						MD_OP_MULL: begin
							accum_window_d = fault_inj33(res_adder_l,2211,2243);
							md_state_d = fault_inj3(MD_IDLE,2244,2246);
						end
						MD_OP_MULH: begin
							accum_window_d = fault_inj33(res_adder_l,2247,2279);
							md_state_d = fault_inj3(MD_IDLE,2280,2282);
						end
						MD_OP_DIV: begin
							accum_window_d = fault_inj33(next_quotient,2283,2315);
							md_state_d = fault_inj3(MD_CHANGE_SIGN,2316,2318);
						end
						default: begin
						accum_window_d = {fault_inj1(1'b0,2319,2319), fault_inj32(next_reminder[31:0],2320,2351)};
						md_state_d = fault_inj3(MD_CHANGE_SIGN,2352,2354);
					end
					endcase
				MD_CHANGE_SIGN: begin
					md_state_d = fault_inj3(MD_FINISH,2355,2357);
					case (fault_inj2(operator_i,2358,2359))
						MD_OP_DIV: accum_window_d = (fault_inj1(div_change_sign,2360,2360) ? fault_inj33(alu_adder_i,2361,2393) : fault_inj33(accum_window_q,2394,2426));
						default: accum_window_d = (fault_inj1(rem_change_sign,2427,2427) ? fault_inj33(alu_adder_i,2428,2460) : fault_inj33(accum_window_q,2461,2493));
					endcase
				end
				MD_FINISH: md_state_d = fault_inj3(MD_IDLE,2494,2496);
				default: md_state_d = 1'bX;
			endcase
	end
	assign valid_o = ((fault_inj3(md_state_q,2497,2499) == fault_inj3(MD_FINISH,2500,2502)) | ((fault_inj3(md_state_q,2503,2505) == fault_inj3(MD_LAST,2506,2508)) & ((fault_inj2(operator_i,2509,2510) == fault_inj2(MD_OP_MULL,2511,2512)) | (fault_inj2(operator_i,2513,2514) == fault_inj2(MD_OP_MULH,2515,2516)))));
endmodule
