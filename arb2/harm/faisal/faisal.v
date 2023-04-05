

`define GENERATE_FAULT_INJECTION_FUNCTION(FUN_NAME, WIDTH) \
	function [WIDTH-1:0] FUN_NAME; \
		input [WIDTH-1:0] _var; \
		input [63:0] toggle_start; \
		input [63:0] toggle_end; \
		reg [WIDTH-1:0] mask; \
    integer f; \
		begin \
			mask = (`fp < toggle_start || `fp > toggle_end) \
				? 0 : (1 << (`fp - toggle_start)); \
			FUN_NAME = _var ^ mask; \
		end \
	endfunction

`define GENERATE_TRANS_FAULT_INJECTION_FUNCTION(FUN_NAME, WIDTH) \
	function [WIDTH-1:0] FUN_NAME; \
		input [WIDTH-1:0] _var; \
		input [63:0] toggle_start; \
		input [63:0] toggle_end; \
		reg [WIDTH-1:0] mask; \
    integer f; \
		begin \
			mask = (`fp < toggle_start || `fp > toggle_end || $urandom%10 !=0) \
				? 0 : (1 << (`fp - toggle_start)); \
			FUN_NAME = _var ^ mask; \
		end \
	endfunction


`define F_PLUS 8'd0
`define F_MINUS 8'd1
`define F_TIMES 8'd2
`define F_DIV 8'd3

`define GENERATE_MUTANT_INJECTION_FUNCTION(FUN_NAME, WIDTH) \
	function [WIDTH-1:0] FUN_NAME; \
		input [WIDTH-1:0] var1; \
		input [WIDTH-1:0] var2; \
		input [7:0] toggle_start; \
		input [7:0] toggle_end; \
		input [4:0] oper; \
		reg    [3:0] flag; \
    integer i, f; \
		begin \
			for (i=0; i<4; i=i+1) begin\
      			if(i>= oper) begin \
        			flag[i] = 1; \
      			end \
      			else begin \
        			flag[i] = 0; \
      			end \
      end \
      		if (`fp < toggle_start || `fp > toggle_end) begin \
      		  case (oper) \
      			 8'd0: FUN_NAME = var1 + var2; \
      			 8'd1: FUN_NAME = var1 - var2; \
      			 8'd2: FUN_NAME = var1 * var2; \
      			 8'd3: FUN_NAME = var1 / var2; \
      		  endcase \
      		end \
      		else begin \
      			case (`fp - toggle_start) \
      				8'd0: begin \
      						if(flag[`fp-toggle_start]) begin \
      							FUN_NAME = var1-var2; \
      						end \
              				else begin \
              					FUN_NAME = var1+var2; \
              				end \
      				end \
      				8'd1: begin \
      						if(flag[`fp-toggle_start]) begin \
      							FUN_NAME = var1*var2; \
      						end \
              				else begin \
              					FUN_NAME = var1-var2; \
              				end \
      				end \
      				8'd2: begin \
      						if(flag[`fp-toggle_start]) begin \
      								FUN_NAME = var1/var2; \
      						end \
              				else begin \
              					FUN_NAME = var1*var2; \
              				end \
      				end \
      			endcase \
      	  end \
      end \
	endfunction

`define F_LAND 8'd0
`define F_LOR 8'd1
`define F_LNOT 8'd2

    
`define GENERATE_MUTANT_INJECTION_LOGIC_FUNCTION(FUN_NAME, WIDTH) \
	function [WIDTH-1:0] FUN_NAME; \
		input [WIDTH-1:0] var1; \
		input [WIDTH-1:0] var2; \
		input [63:0] toggle_start; \
		input [63:0] toggle_end; \
		input [4:0] oper; \
		reg    [2:0] flag; \
    integer i, f; \
		begin \
			for (i=0; i<3; i=i+1) begin \
      			if(i>= oper) begin \
        			flag[i] = 1; \
      			end \
      			else begin \
        			flag[i] = 0; \
      			end \
      end \
      		if (`fp < toggle_start || `fp > toggle_end) begin \
      			case (oper) \
      				8'd0: FUN_NAME = var1 & var2; \
      				8'd1: FUN_NAME = var1 | var2; \
      				8'd2: FUN_NAME =  ~var1; \
      			endcase \
      		end \
      		else begin \
      			case (`fp - toggle_start) \
      				8'd0: begin \
      						if(flag[`fp-toggle_start]) begin \
      							FUN_NAME = var1|var2; \
      						end \
              				else begin \
              					FUN_NAME = var1 & var2; \
              				end \
      				end \
      				8'd1: begin \
      						if(flag[`fp-toggle_start]) begin \
      							FUN_NAME =  ~var1; \
      						end \
              				else begin \
              					FUN_NAME = var1 | var2; \
              				end \
      				end \
      			endcase \
      		end \
        end \
  	endfunction

   
`define F_G 8'd0
`define F_GE 8'd1
`define F_L 8'd2
`define F_LE 8'd3
`define F_E 8'd4
`define F_NE 8'd5

`define GENERATE_MUTANT_INJECTION_RELATIONAL_FUNCTION(FUN_NAME, WIDTH) \
	function [1:0] FUN_NAME; \
		input [WIDTH-1:0] var1; \
		input [WIDTH-1:0] var2; \
		input [7:0] toggle_start; \
		input [7:0] toggle_end; \
		input [4:0] oper; \
		reg    [5:0] flag; \
    integer i, f; \
		begin \
			for (i=0; i<6; i=i+1) begin\
      			if(i>= oper) begin \
        			flag[i] = 1; \
      			end \
      			else begin \
        			flag[i] = 0; \
      			end \
      end \
      		if (`fp < toggle_start || `fp > toggle_end) begin \
      			case (oper) \
      				8'd0: FUN_NAME = var1 > var2; \
      				8'd1: FUN_NAME = var1 >= var2; \
      				8'd2: FUN_NAME = var1 < var2; \
      				8'd3: FUN_NAME = var1 <= var2; \
      				8'd4: FUN_NAME = var1 == var2; \
      				8'd5: FUN_NAME = var1 != var2; \
      			endcase \
      		end \
      		else begin \
      			case (`fp - toggle_start) \
      				8'd0: begin \
      					if(flag[`fp-toggle_start]) begin \
      						FUN_NAME = var1 >= var2; \
      					end \
              			else begin \
              				FUN_NAME = var1 > var2; \
              			end \
      				end \
      				8'd1: begin \
      					if(flag[`fp-toggle_start]) begin \
      						FUN_NAME = var1 < var2; \
      					end \
              			else begin \
              				FUN_NAME = var1 >= var2; \
              			end \
      				end \
      				8'd2: begin \
      					if(flag[`fp-toggle_start]) begin \
      						FUN_NAME = var1 <= var2; \
      					end \
              			else begin \
              				FUN_NAME = var1 < var2; \
              			end \
      				end \
      				8'd3: begin \
      					if(flag[`fp-toggle_start]) begin \
      						FUN_NAME = var1 == var2; \
      					end \
              			else begin \
              				FUN_NAME = var1 <= var2; \
              			end \
      				end \
      				8'd4: begin \
      					if(flag[`fp-toggle_start]) begin \
      						FUN_NAME = var1 != var2; \
      					end \
              			else begin \
              				FUN_NAME = var1 == var2; \
              			end \
      				end \
      			endcase \
      		end \
        end \
    endfunction

`define F_AND 8'd0
`define F_OR 8'd1
`define F_NOT 8'd2

`define GENERATE_MUTANT_INJECTION_BOOLEAN_FUNCTION(FUN_NAME) \
	function  [0:0] FUN_NAME; \
		input [0:0] var1; \
		input [0:0] var2; \
		input [7:0] toggle_start; \
		input [7:0] toggle_end; \
		input [4:0] oper; \
		reg    [2:0] flag; \
    integer i, f; \
		begin \
			for (i=0; i<3; i=i+1) begin \
      			if(i>= oper) begin \
        			flag[i] = 1; \
      			end \
      			else begin \
        			flag[i] = 0; \
      			end \
      end \
      		if (`fp < toggle_start || `fp > toggle_end) begin \
      			case (oper) \
      				8'd0: FUN_NAME = var1 && var2; \
      				8'd1: FUN_NAME = var1 || var2; \
      				8'd2: FUN_NAME =  !var1; \
      			endcase \
      		end \
      		else begin \
      			case (`fp - toggle_start) \
      				8'd0: begin \
      						if(flag[`fp-toggle_start]) begin \
      							FUN_NAME = var1||var2; \
      						end \
              				else begin \
              					FUN_NAME = var1 && var2; \
              				end \
      				end \
      				8'd1: begin \
      						if(flag[`fp-toggle_start]) begin \
      							FUN_NAME =  !var1; \
      						end \
              				else begin \
              					FUN_NAME = var1 || var2; \
              				end \
      				end \
      			endcase \
      		end \
        end \
  	endfunction 
