`include "faisal.v"
module ibex_controller (
	clk_i,
	rst_ni,
	fetch_enable_i,
	ctrl_busy_o,
	illegal_insn_i,
	ecall_insn_i,
	mret_insn_i,
	dret_insn_i,
	wfi_insn_i,
	ebrk_insn_i,
	csr_pipe_flush_i,
	instr_valid_i,
	instr_i,
	instr_compressed_i,
	instr_is_compressed_i,
	instr_fetch_err_i,
	pc_id_i,
	instr_valid_clear_o,
	id_in_ready_o,
	instr_req_o,
	pc_set_o,
	pc_mux_o,
	exc_pc_mux_o,
	exc_cause_o,
	lsu_addr_last_i,
	load_err_i,
	store_err_i,
	branch_set_i,
	jump_set_i,
	csr_mstatus_mie_i,
	csr_msip_i,
	csr_mtip_i,
	csr_meip_i,
	csr_mfip_i,
	irq_pending_i,
	irq_nm_i,
	debug_req_i,
	debug_cause_o,
	debug_csr_save_o,
	debug_mode_o,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	csr_save_if_o,
	csr_save_id_o,
	csr_restore_mret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	csr_mtval_o,
	priv_mode_i,
	csr_mstatus_tw_i,
	stall_lsu_i,
	stall_multdiv_i,
	stall_jump_i,
	stall_branch_i,
	perf_jump_o,
	perf_tbranch_o
);
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj1, 1)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj2, 2)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj3, 3)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj4, 4)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj5, 5)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj6, 6)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj15, 16)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj16, 16)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj32, 32)

	localparam [3:0] RESET = 0;
	localparam [3:0] BOOT_SET = 1;
	localparam [3:0] WAIT_SLEEP = 2;
	localparam [3:0] SLEEP = 3;
	localparam [3:0] FIRST_FETCH = 4;
	localparam [3:0] DECODE = 5;
	localparam [3:0] FLUSH = 6;
	localparam [3:0] IRQ_TAKEN = 7;
	localparam [3:0] DBG_TAKEN_IF = 8;
	localparam [3:0] DBG_TAKEN_ID = 9;
	input wire clk_i;
	input wire rst_ni;
	input wire fetch_enable_i;
	output reg ctrl_busy_o;
	input wire illegal_insn_i;
	input wire ecall_insn_i;
	input wire mret_insn_i;
	input wire dret_insn_i;
	input wire wfi_insn_i;
	input wire ebrk_insn_i;
	input wire csr_pipe_flush_i;
	input wire instr_valid_i;
	input wire [31:0] instr_i;
	input wire [15:0] instr_compressed_i;
	input wire instr_is_compressed_i;
	input wire instr_fetch_err_i;
	input wire [31:0] pc_id_i;
	output wire instr_valid_clear_o;
	output wire id_in_ready_o;
	output reg instr_req_o;
	output reg pc_set_o;
	output reg [2:0] pc_mux_o;
	output reg [1:0] exc_pc_mux_o;
	output reg [5:0] exc_cause_o;
	input wire [31:0] lsu_addr_last_i;
	input wire load_err_i;
	input wire store_err_i;
	input wire branch_set_i;
	input wire jump_set_i;
	input wire csr_mstatus_mie_i;
	input wire csr_msip_i;
	input wire csr_mtip_i;
	input wire csr_meip_i;
	input wire [14:0] csr_mfip_i;
	input wire irq_pending_i;
	input wire irq_nm_i;
	input wire debug_req_i;
	output reg [2:0] debug_cause_o;
	output reg debug_csr_save_o;
	output wire debug_mode_o;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	output reg csr_save_if_o;
	output reg csr_save_id_o;
	output reg csr_restore_mret_id_o;
	output reg csr_restore_dret_id_o;
	output reg csr_save_cause_o;
	output reg [31:0] csr_mtval_o;
	input wire [1:0] priv_mode_i;
	input wire csr_mstatus_tw_i;
	input wire stall_lsu_i;
	input wire stall_multdiv_i;
	input wire stall_jump_i;
	input wire stall_branch_i;
	output reg perf_jump_o;
	output reg perf_tbranch_o;
	`include "ibex_pkg.v"
	reg [3:0] ctrl_fsm_cs;
	reg [3:0] ctrl_fsm_ns;
	reg nmi_mode_q;
	reg nmi_mode_d;
	reg debug_mode_q;
	reg debug_mode_d;
	reg load_err_q;
	wire load_err_d;
	reg store_err_q;
	wire store_err_d;
	reg exc_req_q;
	wire exc_req_d;
	reg illegal_insn_q;
	wire illegal_insn_d;
	wire stall;
	reg halt_if;
	reg flush_id;
	wire illegal_dret;
	wire illegal_umode;
	wire exc_req_lsu;
	wire special_req;
	wire enter_debug_mode;
	wire ebreak_into_debug;
	wire handle_irq;
	reg [3:0] mfip_id;
	wire unused_csr_mtip;
	wire ecall_insn;
	wire mret_insn;
	wire dret_insn;
	wire wfi_insn;
	wire ebrk_insn;
	wire csr_pipe_flush;
	wire instr_fetch_err;
	/* 
	NO $display allowed in Verilog code that will go thorugh GM static
	analysis
	always @(negedge clk_i)
		if (((((fault_inj1(ctrl_fsm_cs,1,1) == DECODE) && fault_inj1(instr_valid_i,2,2)) && !instr_fetch_err_i) && fault_inj1(illegal_insn_d,3,3)))
			$display("%t: Illegal instruction (hart %0x) at PC 0x%h: 0x%h", $time, ibex_core.hart_id_i, ibex_id_stage.pc_id_i, ibex_id_stage.instr_rdata_i);
	*/
	assign load_err_d = fault_inj1(load_err_i,4,4);
	assign store_err_d = fault_inj1(store_err_i,5,5);
	assign ecall_insn = (fault_inj1(ecall_insn_i,6,6) & fault_inj1(instr_valid_i,7,7));
	assign mret_insn = (fault_inj1(mret_insn_i,8,8) & fault_inj1(instr_valid_i,9,9));
	assign dret_insn = (fault_inj1(dret_insn_i,10,10) & fault_inj1(instr_valid_i,11,11));
	assign wfi_insn = (fault_inj1(wfi_insn_i,12,12) & fault_inj1(instr_valid_i,13,13));
	assign ebrk_insn = (fault_inj1(ebrk_insn_i,14,14) & fault_inj1(instr_valid_i,15,15));
	assign csr_pipe_flush = (fault_inj1(csr_pipe_flush_i,16,16) & fault_inj1(instr_valid_i,17,17));
	assign instr_fetch_err = (fault_inj1(instr_fetch_err_i,18,18) & fault_inj1(instr_valid_i,19,19));
	assign illegal_dret = (fault_inj1(dret_insn,20,20) & ~fault_inj1(debug_mode_q,21,21));
	assign illegal_umode = ((fault_inj2(priv_mode_i,22,23) != fault_inj2(PRIV_LVL_M,24,25)) & (fault_inj1(mret_insn,26,26) | (fault_inj1(csr_mstatus_tw_i,27,27) & fault_inj1(wfi_insn,28,28))));
	assign illegal_insn_d = (((fault_inj1(illegal_insn_i,29,29) | fault_inj1(illegal_dret,30,30)) | fault_inj1(illegal_umode,31,31)) & (fault_inj4(ctrl_fsm_cs,32,35) != fault_inj4(FLUSH,36,39)));
	assign exc_req_d = ((((fault_inj1(ecall_insn,40,40) | fault_inj1(ebrk_insn,41,41)) | fault_inj1(illegal_insn_d,42,42)) | fault_inj1(instr_fetch_err,43,43)) & (fault_inj4(ctrl_fsm_cs,44,47) != fault_inj4(FLUSH,48,51)));
	assign exc_req_lsu = (fault_inj1(store_err_i,52,52) | fault_inj1(load_err_i,53,53));
	assign special_req = (((((fault_inj1(mret_insn,54,54) | fault_inj1(dret_insn,55,55)) | fault_inj1(wfi_insn,56,56)) | fault_inj1(csr_pipe_flush,57,57)) | fault_inj1(exc_req_d,58,58)) | fault_inj1(exc_req_lsu,59,59));
	assign enter_debug_mode = ((fault_inj1(debug_req_i,60,60) | (fault_inj1(debug_single_step_i,61,61) & fault_inj1(instr_valid_i,62,62))) & ~fault_inj1(debug_mode_q,63,63));
	assign ebreak_into_debug = ((fault_inj2(priv_mode_i,64,65) == fault_inj2(PRIV_LVL_M,66,67)) ? debug_ebreakm_i : ((fault_inj2(priv_mode_i,68,69) == fault_inj2(PRIV_LVL_U,70,71)) ? fault_inj1(debug_ebreaku_i,72,72) : fault_inj1(1'b0,73,73)));
	assign handle_irq = (~fault_inj1(debug_mode_q,74,74) & ((fault_inj1(irq_nm_i,75,75) & ~fault_inj1(nmi_mode_q,76,76)) | (fault_inj1(irq_pending_i,77,77) & fault_inj1(csr_mstatus_mie_i,78,78))));
	always @(*) begin : gen_mfip_id
		if (fault_inj15(csr_mfip_i[14],79,93))
			mfip_id = fault_inj4(4'd14,94,97);
		else if (fault_inj15(csr_mfip_i[13],98,112))
			mfip_id = fault_inj4(4'd13,113,116);
		else if (fault_inj15(csr_mfip_i[12],117,131))
			mfip_id = fault_inj4(4'd12,132,135);
		else if (fault_inj15(csr_mfip_i[11],136,150))
			mfip_id = fault_inj4(4'd11,151,154);
		else if (fault_inj15(csr_mfip_i[10],155,169))
			mfip_id = fault_inj4(4'd10,170,173);
		else if (fault_inj15(csr_mfip_i[9],174,188))
			mfip_id = fault_inj4(4'd9,189,192);
		else if (fault_inj15(csr_mfip_i[8],193,207))
			mfip_id = fault_inj4(4'd8,208,211);
		else if (fault_inj15(csr_mfip_i[7],212,226))
			mfip_id = fault_inj4(4'd7,227,230);
		else if (fault_inj15(csr_mfip_i[6],231,245))
			mfip_id = fault_inj4(4'd6,246,249);
		else if (fault_inj15(csr_mfip_i[5],250,264))
			mfip_id = fault_inj4(4'd5,265,268);
		else if (fault_inj15(csr_mfip_i[5],269,283))
			mfip_id = fault_inj4(4'd5,284,287);
		else if (fault_inj15(csr_mfip_i[4],288,302))
			mfip_id = fault_inj4(4'd4,303,306);
		else if (fault_inj15(csr_mfip_i[3],307,321))
			mfip_id = fault_inj4(4'd3,322,325);
		else if (fault_inj15(csr_mfip_i[2],326,340))
			mfip_id = fault_inj4(4'd2,341,344);
		else if (fault_inj15(csr_mfip_i[1],345,359))
			mfip_id = fault_inj4(4'd1,360,363);
		else
			mfip_id = fault_inj4(4'd0,364,367);
	end
	assign unused_csr_mtip = fault_inj1(csr_mtip_i,368,368);
	always @(*) begin
		instr_req_o = fault_inj1(1'b1,369,369);
		csr_save_if_o = fault_inj1(1'b0,370,370);
		csr_save_id_o = fault_inj1(1'b0,371,371);
		csr_restore_mret_id_o = fault_inj1(1'b0,372,372);
		csr_restore_dret_id_o = fault_inj1(1'b0,373,373);
		csr_save_cause_o = fault_inj1(1'b0,374,374);
		csr_mtval_o = fault_inj1(1'sb0,375,375);
		pc_mux_o = fault_inj3(PC_BOOT,376,378);
		pc_set_o = fault_inj1(1'b0,379,379);
		exc_pc_mux_o = fault_inj2(EXC_PC_IRQ,380,381);
		exc_cause_o = fault_inj6(EXC_CAUSE_INSN_ADDR_MISA,382,387);
		ctrl_fsm_ns = fault_inj4(ctrl_fsm_cs,388,391);
		ctrl_busy_o = fault_inj1(1'b1,392,392);
		halt_if = fault_inj1(1'b0,393,393);
		flush_id = fault_inj1(1'b0,394,394);
		debug_csr_save_o = fault_inj1(1'b0,395,395);
		debug_cause_o = fault_inj3(DBG_CAUSE_EBREAK,396,398);
		debug_mode_d = fault_inj1(debug_mode_q,399,399);
		nmi_mode_d = fault_inj1(nmi_mode_q,400,400);
		perf_tbranch_o = fault_inj1(1'b0,401,401);
		perf_jump_o = fault_inj1(1'b0,402,402);
		case (fault_inj4(ctrl_fsm_cs,403,406))
		    RESET: begin
				instr_req_o = fault_inj1(1'b0,407,407);
				pc_mux_o = fault_inj3(PC_BOOT,408,410);
				pc_set_o = fault_inj1(1'b1,411,411);
				if (fault_inj1(fetch_enable_i,412,412))
					ctrl_fsm_ns = fault_inj4(BOOT_SET,413,416);
			end
            BOOT_SET: begin
				instr_req_o = fault_inj1(1'b1,417,417);
				pc_mux_o = fault_inj3(PC_BOOT,418,420);
				pc_set_o = fault_inj1(1'b1,421,421);
				ctrl_fsm_ns = fault_inj4(FIRST_FETCH,422,425);
			end
			WAIT_SLEEP: begin
				ctrl_busy_o = fault_inj1(1'b0,426,426);
				instr_req_o = fault_inj1(1'b0,427,427);
				halt_if = fault_inj1(1'b1,428,428);
				flush_id = fault_inj1(1'b1,429,429);
				ctrl_fsm_ns = fault_inj4(SLEEP,430,433);
			end
			SLEEP: begin
				instr_req_o = fault_inj1(1'b0,434,434);
				halt_if = fault_inj1(1'b1,435,435);
				flush_id = fault_inj1(1'b1,436,436);
				if (((((fault_inj1(irq_nm_i,437,437) || fault_inj1(irq_pending_i,438,438)) || fault_inj1(debug_req_i,439,439)) || fault_inj1(debug_mode_q,440,440)) || fault_inj1(debug_single_step_i,441,441)))
					ctrl_fsm_ns = fault_inj4(FIRST_FETCH,442,445);
				else
					ctrl_busy_o = fault_inj1(1'b0,446,446);
			end
			FIRST_FETCH: begin
				if (fault_inj1(id_in_ready_o,447,447))
					ctrl_fsm_ns = fault_inj4(DECODE,448,451);
				if (fault_inj1(handle_irq,452,452)) begin
					ctrl_fsm_ns = fault_inj4(IRQ_TAKEN,453,456);
					halt_if = fault_inj1(1'b1,457,457);
					flush_id = fault_inj1(1'b1,458,458);
				end
				if (fault_inj1(enter_debug_mode,459,459)) begin
					ctrl_fsm_ns = fault_inj4(DBG_TAKEN_IF,460,463);
					halt_if = fault_inj1(1'b1,464,464);
				end
			end
			DECODE: begin
				if (fault_inj1(instr_valid_i,465,465)) begin
					if (fault_inj1(special_req,466,466)) begin
						ctrl_fsm_ns = fault_inj4(FLUSH,467,470);
						halt_if = fault_inj1(1'b1,471,471);
					end
					else if ((fault_inj1(branch_set_i,472,472) || fault_inj1(jump_set_i,473,473))) begin
						pc_mux_o = fault_inj3(PC_JUMP,474,476);
						pc_set_o = fault_inj1(1'b1,477,477);
						perf_tbranch_o = fault_inj1(branch_set_i,478,478);
						perf_jump_o = fault_inj1(jump_set_i,479,479);
					end
					if (((fault_inj1(enter_debug_mode,480,480) || fault_inj1(handle_irq,481,481)) && fault_inj1(stall,482,482)))
						halt_if = fault_inj1(1'b1,483,483);
				end
				if ((!fault_inj1(stall,484,484) && !fault_inj1(special_req,485,485)))
					if (fault_inj1(enter_debug_mode,486,486)) begin
						ctrl_fsm_ns = fault_inj4(DBG_TAKEN_IF,487,490);
						halt_if = fault_inj1(1'b1,491,491);
					end
					else if (fault_inj1(handle_irq,492,492)) begin
						ctrl_fsm_ns = fault_inj4(IRQ_TAKEN,493,496);
						halt_if = fault_inj1(1'b1,497,497);
						flush_id = fault_inj1(1'b1,498,498);
					end
			end
			IRQ_TAKEN: begin
				if (fault_inj1(handle_irq,499,499)) begin
					pc_mux_o = fault_inj3(PC_EXC,500,502);
					pc_set_o = fault_inj1(1'b1,503,503);
					exc_pc_mux_o = fault_inj2(EXC_PC_IRQ,504,505);
					csr_save_if_o = fault_inj1(1'b1,506,506);
					csr_save_cause_o = fault_inj1(1'b1,507,507);
					if ((fault_inj1(irq_nm_i,508,508) && !fault_inj1(nmi_mode_q,509,509))) begin
						exc_cause_o = fault_inj6(EXC_CAUSE_IRQ_NM,510,515);
						nmi_mode_d = fault_inj1(1'b1,516,516);
					end
					else if ((fault_inj15(csr_mfip_i,517,531) != fault_inj15(15'b0,532,546)))
						exc_cause_o = sv2v_cast_89EA8({fault_inj2(2'b11,547,548), fault_inj4(mfip_id,549,552)});
					else if (fault_inj1(csr_meip_i,553,553))
						exc_cause_o = fault_inj6(EXC_CAUSE_IRQ_EXTERNAL_M,554,559);
					else if (fault_inj1(csr_msip_i,560,560))
						exc_cause_o = fault_inj6(EXC_CAUSE_IRQ_SOFTWARE_M,561,566);
					else
						exc_cause_o = fault_inj6(EXC_CAUSE_IRQ_TIMER_M,567,572);
				end
				ctrl_fsm_ns = fault_inj4(DECODE,573,576);
			end
			DBG_TAKEN_IF: begin
				if ((fault_inj1(debug_single_step_i,577,577) || fault_inj1(debug_req_i,578,578))) begin
					flush_id = fault_inj1(1'b1,579,579);
					pc_mux_o = fault_inj3(PC_EXC,580,582);
					pc_set_o = fault_inj1(1'b1,583,583);
					exc_pc_mux_o = fault_inj2(EXC_PC_DBD,584,585);
					csr_save_if_o = fault_inj1(1'b1,586,586);
					debug_csr_save_o = fault_inj1(1'b1,587,587);
					csr_save_cause_o = fault_inj1(1'b1,588,588);
					if (fault_inj1(debug_single_step_i,589,589))
						debug_cause_o = fault_inj3(DBG_CAUSE_STEP,590,592);
					else
						debug_cause_o = fault_inj3(DBG_CAUSE_HALTREQ,593,595);
					debug_mode_d = fault_inj1(1'b1,596,596);
				end
				ctrl_fsm_ns = fault_inj4(DECODE,597,600);
			end
			DBG_TAKEN_ID: begin
				flush_id = fault_inj1(1'b1,601,601);
				pc_mux_o = fault_inj3(PC_EXC,602,604);
				pc_set_o = fault_inj1(1'b1,605,605);
				exc_pc_mux_o = fault_inj2(EXC_PC_DBD,606,607);
				if ((fault_inj1(ebreak_into_debug,608,608) && fault_inj1(!debug_mode_q,609,609))) begin
					csr_save_cause_o = fault_inj1(1'b1,610,610);
					csr_save_id_o = fault_inj1(1'b1,611,611);
					debug_csr_save_o = fault_inj1(1'b1,612,612);
					debug_cause_o = fault_inj3(DBG_CAUSE_EBREAK,613,615);
				end
				debug_mode_d = fault_inj1(1'b1,616,616);
				ctrl_fsm_ns = fault_inj4(DECODE,617,620);
			end
			FLUSH: begin
				halt_if = fault_inj1(1'b1,621,621);
				flush_id = fault_inj1(1'b1,622,622);
				ctrl_fsm_ns = fault_inj4(DECODE,623,626);
				if (((fault_inj1(exc_req_q,627,627) || fault_inj1(store_err_q,628,628)) || fault_inj1(load_err_q,629,629))) begin
					pc_set_o = fault_inj1(1'b1,630,630);
					pc_mux_o = fault_inj3(PC_EXC,631,633);
					exc_pc_mux_o = (fault_inj1(debug_mode_q,634,634) ? fault_inj2(EXC_PC_DBG_EXC,635,636) : fault_inj2(EXC_PC_EXC,637,638));
					csr_save_id_o = fault_inj1(1'b1,639,639);
					csr_save_cause_o = fault_inj1(1'b1,640,640);
					if (fault_inj1(instr_fetch_err,641,641)) begin
						exc_cause_o = fault_inj6(EXC_CAUSE_INSTR_ACCESS_FAULT,642,647);
						csr_mtval_o = fault_inj32(pc_id_i,648,679);
					end
					else if (fault_inj1(illegal_insn_q,680,680)) begin
						exc_cause_o = fault_inj6(EXC_CAUSE_ILLEGAL_INSN,681,686);
						csr_mtval_o = (fault_inj1(instr_is_compressed_i,687,687) ? {fault_inj16(16'b0,688,703), fault_inj16(instr_compressed_i,704,719)} : fault_inj32(instr_i,720,751));
					end
					else if (fault_inj1(ecall_insn,752,752))
						exc_cause_o = ((fault_inj2(priv_mode_i,753,754) == fault_inj2(PRIV_LVL_M,755,756)) ? fault_inj6(EXC_CAUSE_ECALL_MMODE,757,762) : fault_inj6(EXC_CAUSE_ECALL_UMODE,763,768));
					else if (fault_inj1(ebrk_insn,769,769)) begin
						if ((fault_inj1(debug_mode_q,770,770) | fault_inj1(ebreak_into_debug,771,771))) begin
							pc_set_o = fault_inj1(1'b0,772,772);
							csr_save_id_o = fault_inj1(1'b0,773,773);
							csr_save_cause_o = fault_inj1(1'b0,774,774);
							ctrl_fsm_ns = fault_inj4(DBG_TAKEN_ID,775,778);
							flush_id = fault_inj1(1'b0,779,779);
						end
						else
							exc_cause_o = fault_inj6(EXC_CAUSE_BREAKPOINT,780,785);
					end
					else if (fault_inj1(store_err_q,786,786)) begin
						exc_cause_o = fault_inj6(EXC_CAUSE_STORE_ACCESS_FAULT,787,792);
						csr_mtval_o = fault_inj32(lsu_addr_last_i,793,824);
					end
					else begin
						exc_cause_o = fault_inj6(EXC_CAUSE_LOAD_ACCESS_FAULT,825,830);
						csr_mtval_o = fault_inj32(lsu_addr_last_i,831,862);
					end
				end
				else if (fault_inj1(mret_insn,863,863)) begin
					pc_mux_o = fault_inj3(PC_ERET,864,866);
					pc_set_o = fault_inj1(1'b1,867,867);
					csr_restore_mret_id_o = fault_inj1(1'b1,868,868);
					if (fault_inj1(nmi_mode_q,869,869))
						nmi_mode_d = fault_inj1(1'b0,870,870);
				end
				else if (fault_inj1(dret_insn,871,871)) begin
					pc_mux_o = fault_inj3(PC_DRET,872,874);
					pc_set_o = fault_inj1(1'b1,875,875);
					debug_mode_d = fault_inj1(1'b0,876,876);
					csr_restore_dret_id_o = fault_inj1(1'b1,877,877);
				end
				else if (fault_inj1(wfi_insn,878,878))
					ctrl_fsm_ns = fault_inj4(WAIT_SLEEP,879,882);
				else if ((fault_inj1(csr_pipe_flush,883,883) && fault_inj1(handle_irq,884,884)))
					ctrl_fsm_ns = fault_inj4(IRQ_TAKEN,885,888);
				if (fault_inj1(enter_debug_mode,889,889))
					ctrl_fsm_ns = fault_inj4(DBG_TAKEN_IF,890,893);
			end
			default: begin
			instr_req_o = fault_inj1(1'b0,894,894);
			ctrl_fsm_ns = 1'bX;
		end
		endcase
	end
	assign debug_mode_o = fault_inj1(debug_mode_q,895,895);
	assign stall = (((fault_inj1(stall_lsu_i,896,896) | fault_inj1(stall_multdiv_i,897,897)) | fault_inj1(stall_jump_i,898,898)) | fault_inj1(stall_branch_i,899,899));
	assign id_in_ready_o = (~fault_inj1(stall,900,900) & ~fault_inj1(halt_if,901,901));
	assign instr_valid_clear_o = (~(fault_inj1(stall,902,902) | fault_inj1(halt_if,903,903)) | fault_inj1(flush_id,904,904));
	always @(posedge clk_i or negedge rst_ni) begin : update_regs
		if (!fault_inj1(rst_ni,905,905)) begin
			ctrl_fsm_cs <= fault_inj4(RESET,906,909);
			nmi_mode_q <= fault_inj1(1'b0,910,910);
			debug_mode_q <= fault_inj1(1'b0,911,911);
			load_err_q <= fault_inj1(1'b0,912,912);
			store_err_q <= fault_inj1(1'b0,913,913);
			exc_req_q <= fault_inj1(1'b0,914,914);
			illegal_insn_q <= fault_inj1(1'b0,915,915);
		end
		else begin
			ctrl_fsm_cs <= fault_inj4(ctrl_fsm_ns,916,919);
			nmi_mode_q <= fault_inj1(nmi_mode_d,920,920);
			debug_mode_q <= fault_inj1(debug_mode_d,921,921);
			load_err_q <= fault_inj1(load_err_d,922,922);
			store_err_q <= fault_inj1(store_err_d,923,923);
			exc_req_q <= fault_inj1(exc_req_d,924,924);
			illegal_insn_q <= fault_inj1(illegal_insn_d,925,925);
		end
	end
	function [(6 - 1):0] sv2v_cast_89EA8;
		input [(6 - 1):0] inp;
		sv2v_cast_89EA8 = fault_inj1(inp,926,926);
	endfunction
endmodule
