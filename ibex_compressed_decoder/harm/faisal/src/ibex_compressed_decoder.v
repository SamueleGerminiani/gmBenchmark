`include "faisal.v"
module ibex_compressed_decoder (
	instr_i,
	instr_o,
	is_compressed_o,
	illegal_instr_o,
    clk
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
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj32, 32)

	input wire [31:0] instr_i;
	output reg [31:0] instr_o;
    input wire clk ;
	output wire is_compressed_o;
	output reg illegal_instr_o;
	`include "ibex_pkg.v"
	always @(*) begin
		illegal_instr_o = fault_inj1(1'b0,1,1);
		instr_o = 1'bX;
		case (fault_inj2(instr_i[1:0],2,3))
			2'b00:
				case (fault_inj3(instr_i[15:13],4,6))
					3'b000: begin
						instr_o = {fault_inj2(2'b0,7,8), fault_inj4(instr_i[10:7],9,12), fault_inj2(instr_i[12:11],13,14), fault_inj1(instr_i[5],15,15), fault_inj1(instr_i[6],16,16), fault_inj2(2'b00,17,18), fault_inj5(5'h02,19,23), fault_inj3(3'b000,24,26), fault_inj2(2'b01,27,28), fault_inj3(instr_i[4:2],29,31), fault_inj7(OPCODE_OP_IMM,32,38)};
						if ((fault_inj8(instr_i[12:5],39,46) == fault_inj8(8'b0,47,54)))
							illegal_instr_o = fault_inj1(1'b1,55,55);
					end
					3'b010: instr_o = {fault_inj5(5'b0,56,60), fault_inj1(instr_i[5],61,61), fault_inj3(instr_i[12:10],62,64), fault_inj1(instr_i[6],65,65), fault_inj2(2'b00,66,67), fault_inj2(2'b01,68,69), fault_inj3(instr_i[9:7],70,72), fault_inj3(3'b010,73,75), fault_inj2(2'b01,76,77), fault_inj3(instr_i[4:2],78,80), fault_inj7(OPCODE_LOAD,81,87)};
					3'b110: instr_o = {fault_inj5(5'b0,88,92), fault_inj1(instr_i[5],93,93), fault_inj1(instr_i[12],94,94), fault_inj2(2'b01,95,96), fault_inj3(instr_i[4:2],97,99), fault_inj2(2'b01,100,101), fault_inj3(instr_i[9:7],102,104), fault_inj3(3'b010,105,107), fault_inj2(instr_i[11:10],108,109), fault_inj1(instr_i[6],110,110), fault_inj2(2'b00,111,112), fault_inj7(OPCODE_STORE,113,119)};
					default: illegal_instr_o = fault_inj1(1'b1,120,120);
				endcase
			2'b01:
				case (fault_inj3(instr_i[15:13],121,123))
					3'b000: instr_o = {{6 {fault_inj1(instr_i[12],124,124)}}, fault_inj1(instr_i[12],125,125), fault_inj5(instr_i[6:2],126,130), fault_inj5(instr_i[11:7],131,135), fault_inj3(3'b0,136,138), fault_inj5(instr_i[11:7],139,143), fault_inj7(OPCODE_OP_IMM,144,150)};
					3'b001, 3'b101: instr_o = {fault_inj1(instr_i[12],151,151), fault_inj1(instr_i[8],152,152), fault_inj2(instr_i[10:9],153,154), fault_inj1(instr_i[6],155,155), fault_inj1(instr_i[7],156,156), fault_inj1(instr_i[2],157,157), fault_inj1(instr_i[11],158,158), fault_inj3(instr_i[5:3],159,161), {9 {fault_inj1(instr_i[12],162,162)}}, fault_inj4(4'b0,163,166), ~fault_inj1(instr_i[15],167,167), fault_inj7(OPCODE_JAL,168,174)};
					3'b010: instr_o = {{6 {fault_inj1(instr_i[12],175,175)}}, fault_inj1(instr_i[12],176,176), fault_inj5(instr_i[6:2],177,181), fault_inj5(5'b0,182,186), fault_inj3(3'b0,187,189), fault_inj5(instr_i[11:7],190,194), fault_inj7(OPCODE_OP_IMM,195,201)};
					3'b011: begin
						instr_o = {{15 {fault_inj1(instr_i[12],202,202)}}, fault_inj5(instr_i[6:2],203,207), fault_inj5(instr_i[11:7],208,212), fault_inj7(OPCODE_LUI,213,219)};
						if ((fault_inj5(instr_i[11:7],220,224) == fault_inj5(5'h02,225,229)))
							instr_o = {{3 {fault_inj1(instr_i[12],230,230)}}, fault_inj2(instr_i[4:3],231,232), fault_inj1(instr_i[5],233,233), fault_inj1(instr_i[2],234,234), fault_inj1(instr_i[6],235,235), fault_inj4(4'b0,236,239), fault_inj5(5'h02,240,244), fault_inj3(3'b000,245,247), fault_inj5(5'h02,248,252), fault_inj7(OPCODE_OP_IMM,253,259)};
						if (({fault_inj1(instr_i[12],260,260), fault_inj5(instr_i[6:2],261,265)} == fault_inj6(6'b0,266,271)))
							illegal_instr_o = fault_inj1(1'b1,272,272);
					end
					3'b100:
						case (fault_inj2(instr_i[11:10],273,274))
							2'b00, 2'b01: begin
								instr_o = {fault_inj1(1'b0,275,275), fault_inj1(instr_i[10],276,276), fault_inj5(5'b0,277,281), fault_inj5(instr_i[6:2],282,286), fault_inj2(2'b01,287,288), fault_inj3(instr_i[9:7],289,291), fault_inj3(3'b101,292,294), fault_inj2(2'b01,295,296), fault_inj3(instr_i[9:7],297,299), fault_inj7(OPCODE_OP_IMM,300,306)};
								if ((fault_inj1(instr_i[12],307,307) == fault_inj1(1'b1,308,308)))
									illegal_instr_o = fault_inj1(1'b1,309,309);
							end
							2'b10: instr_o = {{6 {fault_inj1(instr_i[12],310,310)}}, fault_inj1(instr_i[12],311,311), fault_inj5(instr_i[6:2],312,316), fault_inj2(2'b01,317,318), fault_inj3(instr_i[9:7],319,321), fault_inj3(3'b111,322,324), fault_inj2(2'b01,325,326), fault_inj3(instr_i[9:7],327,329), fault_inj7(OPCODE_OP_IMM,330,336)};
							2'b11:
								case ({fault_inj1(instr_i[12],337,337), fault_inj2(instr_i[6:5],338,339)})
									3'b000: instr_o = {fault_inj2(2'b01,340,341), fault_inj5(5'b0,342,346), fault_inj2(2'b01,347,348), fault_inj3(instr_i[4:2],349,351), fault_inj2(2'b01,352,353), fault_inj3(instr_i[9:7],354,356), fault_inj3(3'b000,357,359), fault_inj2(2'b01,360,361), fault_inj3(instr_i[9:7],362,364), fault_inj7(OPCODE_OP,365,371)};
									3'b001: instr_o = {fault_inj7(7'b0,372,378), fault_inj2(2'b01,379,380), fault_inj3(instr_i[4:2],381,383), fault_inj2(2'b01,384,385), fault_inj3(instr_i[9:7],386,388), fault_inj3(3'b100,389,391), fault_inj2(2'b01,392,393), fault_inj3(instr_i[9:7],394,396), fault_inj7(OPCODE_OP,397,403)};
									3'b010: instr_o = {fault_inj7(7'b0,404,410), fault_inj2(2'b01,411,412), fault_inj3(instr_i[4:2],413,415), fault_inj2(2'b01,416,417), fault_inj3(instr_i[9:7],418,420), fault_inj3(3'b110,421,423), fault_inj2(2'b01,424,425), fault_inj3(instr_i[9:7],426,428), fault_inj7(OPCODE_OP,429,435)};
									3'b011: instr_o = {fault_inj7(7'b0,436,442), fault_inj2(2'b01,443,444), fault_inj3(instr_i[4:2],445,447), fault_inj2(2'b01,448,449), fault_inj3(instr_i[9:7],450,452), fault_inj3(3'b111,453,455), fault_inj2(2'b01,456,457), fault_inj3(instr_i[9:7],458,460), fault_inj7(OPCODE_OP,461,467)};
									3'b100, 3'b101, 3'b110, 3'b111: illegal_instr_o = fault_inj1(1'b1,468,468);
									default: illegal_instr_o = 1'bX;
								endcase
							default: illegal_instr_o = 1'bX;
						endcase
					3'b110, 3'b111: instr_o = {{4 {fault_inj1(instr_i[12],469,469)}}, fault_inj2(instr_i[6:5],470,471), fault_inj1(instr_i[2],472,472), fault_inj5(5'b0,473,477), fault_inj2(2'b01,478,479), fault_inj3(instr_i[9:7],480,482), fault_inj2(2'b00,483,484), fault_inj1(instr_i[13],485,485), fault_inj2(instr_i[11:10],486,487), fault_inj2(instr_i[4:3],488,489), fault_inj1(instr_i[12],490,490), fault_inj7(OPCODE_BRANCH,491,497)};
					default: illegal_instr_o = 1'bX;
				endcase
			2'b10:
				case (fault_inj3(instr_i[15:13],498,500))
					3'b000: begin
						instr_o = {fault_inj7(7'b0,501,507), fault_inj5(instr_i[6:2],508,512), fault_inj5(instr_i[11:7],513,517), fault_inj3(3'b001,518,520), fault_inj5(instr_i[11:7],521,525), fault_inj7(OPCODE_OP_IMM,526,532)};
						if ((fault_inj1(instr_i[12],533,533) == fault_inj1(1'b1,534,534)))
							illegal_instr_o = fault_inj1(1'b1,535,535);
					end
					3'b010: begin
						instr_o = {fault_inj4(4'b0,536,539), fault_inj2(instr_i[3:2],540,541), fault_inj1(instr_i[12],542,542), fault_inj3(instr_i[6:4],543,545), fault_inj2(2'b00,546,547), fault_inj5(5'h02,548,552), fault_inj3(3'b010,553,555), fault_inj5(instr_i[11:7],556,560), fault_inj7(OPCODE_LOAD,561,567)};
						if ((fault_inj5(instr_i[11:7],568,572) == fault_inj5(5'b0,573,577)))
							illegal_instr_o = fault_inj1(1'b1,578,578);
					end
					3'b100:
						if ((fault_inj1(instr_i[12],579,579) == fault_inj1(1'b0,580,580))) begin
							if ((fault_inj5(instr_i[6:2],581,585) != fault_inj5(5'b0,586,590)))
								instr_o = {fault_inj7(7'b0,591,597), fault_inj3(instr_i[6:2],598,600), fault_inj5(5'b0,601,605), fault_inj3(3'b0,606,608), fault_inj5(instr_i[11:7],609,613), fault_inj7(OPCODE_OP,614,620)};
							else begin
								instr_o = {fault_inj12(12'b0,621,632), fault_inj5(instr_i[11:7],633,637), fault_inj3(3'b0,638,640), fault_inj5(5'b0,641,645), fault_inj7(OPCODE_JALR,646,652)};
								if ((fault_inj5(instr_i[11:7],653,657) == fault_inj5(5'b0,658,662)))
									illegal_instr_o = fault_inj1(1'b1,663,663);
							end
						end
						else if ((fault_inj5(instr_i[6:2],664,668) != fault_inj5(5'b0,669,673)))
							instr_o = {fault_inj7(7'b0,674,680), fault_inj5(instr_i[6:2],681,685), fault_inj5(instr_i[11:7],686,690), fault_inj3(3'b0,691,693), fault_inj5(instr_i[11:7],694,698), fault_inj7(OPCODE_OP,699,705)};
						else if ((fault_inj5(instr_i[11:7],706,710) == fault_inj5(5'b0,711,715)))
							instr_o = fault_inj32(32'h00_10_00_73,716,747);
						else
							instr_o = {fault_inj12(12'b0,748,759), fault_inj5(instr_i[11:7],760,764), fault_inj3(3'b000,765,767), fault_inj5(5'b00001,768,772), fault_inj7(OPCODE_JALR,773,779)};
					3'b110: instr_o = {fault_inj4(4'b0,780,783), fault_inj2(instr_i[8:7],784,785), fault_inj1(instr_i[12],786,786), fault_inj5(instr_i[6:2],787,791), fault_inj5(5'h02,792,796), fault_inj3(3'b010,797,799), fault_inj3(instr_i[11:9],800,802), fault_inj2(2'b00,803,804), fault_inj7(OPCODE_STORE,805,811)};
					3'b001, 3'b011, 3'b101, 3'b111: illegal_instr_o = fault_inj1(1'b1,812,812);
					default: illegal_instr_o = 1'bX;
				endcase
			default: instr_o = fault_inj32(instr_i,813,844);
		endcase
	end
	assign is_compressed_o = (fault_inj2(instr_i[1:0],845,846) != fault_inj2(2'b11,847,848));
endmodule
