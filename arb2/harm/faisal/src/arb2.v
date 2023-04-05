`include "faisal.v"
module arb2(clk, rst, req1, req2, gnt1, gnt2);
`GENERATE_FAULT_INJECTION_FUNCTION(fault_inj1, 1)

input clk, rst;
input req1, req2;
output gnt1, gnt2;

reg state;
reg gnt1, gnt2;

always @ (posedge clk or posedge rst)
	if (fault_inj1(rst,1,1))
		state <= fault_inj1(0,2,2);
	else
		state <= fault_inj1(gnt1,3,3);

always @ (*)
	if (fault_inj1(state,4,4))
	begin
		gnt1 = fault_inj1(req1,5,5) & fault_inj1(~fault_inj1(req2,6,6),7,7);
		gnt2 = fault_inj1(req2,8,8);
	end
	else
	begin
		gnt1 = fault_inj1(req1,9,9);
		gnt2 = fault_inj1(req2,10,10) & fault_inj1(~fault_inj1(req1,11,11),12,12);
	end

endmodule
