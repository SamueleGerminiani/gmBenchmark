`include "faisal.v"
module ibex_id_stage (
	clk_i,
	rst_ni,
	test_en_i,
	fetch_enable_i,
	ctrl_busy_o,
	illegal_insn_o,
	instr_valid_i,
	instr_new_i,
	instr_rdata_i,
	instr_rdata_c_i,
	instr_is_compressed_i,
	instr_req_o,
	instr_valid_clear_o,
	id_in_ready_o,
	branch_decision_i,
	pc_set_o,
	pc_mux_o,
	exc_pc_mux_o,
	exc_cause_o,
	illegal_c_insn_i,
	instr_fetch_err_i,
	pc_id_i,
	ex_valid_i,
	lsu_valid_i,
	alu_operator_ex_o,
	alu_operand_a_ex_o,
	alu_operand_b_ex_o,
	mult_en_ex_o,
	div_en_ex_o,
	multdiv_operator_ex_o,
	multdiv_signed_mode_ex_o,
	multdiv_operand_a_ex_o,
	multdiv_operand_b_ex_o,
	csr_access_o,
	csr_op_o,
	csr_save_if_o,
	csr_save_id_o,
	csr_restore_mret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	csr_mtval_o,
	priv_mode_i,
	csr_mstatus_tw_i,
	illegal_csr_insn_i,
	data_req_ex_o,
	data_we_ex_o,
	data_type_ex_o,
	data_sign_ext_ex_o,
	data_wdata_ex_o,
	lsu_addr_incr_req_i,
	lsu_addr_last_i,
	csr_mstatus_mie_i,
	csr_msip_i,
	csr_mtip_i,
	csr_meip_i,
	csr_mfip_i,
	irq_pending_i,
	irq_nm_i,
	lsu_load_err_i,
	lsu_store_err_i,
	debug_mode_o,
	debug_cause_o,
	debug_csr_save_o,
	debug_req_i,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	regfile_wdata_lsu_i,
	regfile_wdata_ex_i,
	csr_rdata_i,
	rfvi_reg_raddr_ra_o,
	rfvi_reg_rdata_ra_o,
	rfvi_reg_raddr_rb_o,
	rfvi_reg_rdata_rb_o,
	rfvi_reg_waddr_rd_o,
	rfvi_reg_wdata_rd_o,
	rfvi_reg_we_o,
	perf_jump_o,
	perf_branch_o,
	perf_tbranch_o,
	instr_ret_o,
	instr_ret_compressed_o
);
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj1, 1)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj2, 2)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj3, 3)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj4, 4)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj5, 5)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj6, 6)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj16, 16)
`GENERATE_FAULT_INJECTION_BIT_FLIP_FUNCTION(fault_inj32, 32)

	localparam [0:0] IDLE = 0;
	localparam [0:0] WAIT_MULTICYCLE = 1;
	parameter RV32E = 0;
	parameter RV32M = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire fetch_enable_i;
	output wire ctrl_busy_o;
	output wire illegal_insn_o;
	input wire instr_valid_i;
	input wire instr_new_i;
	input wire [31:0] instr_rdata_i;
	input wire [15:0] instr_rdata_c_i;
	input wire instr_is_compressed_i;
	output wire instr_req_o;
	output wire instr_valid_clear_o;
	output wire id_in_ready_o;
	input wire branch_decision_i;
	output wire pc_set_o;
	output wire [2:0] pc_mux_o;
	output wire [1:0] exc_pc_mux_o;
	output wire [5:0] exc_cause_o;
	input wire illegal_c_insn_i;
	input wire instr_fetch_err_i;
	input wire [31:0] pc_id_i;
	input wire ex_valid_i;
	input wire lsu_valid_i;
	output wire [4:0] alu_operator_ex_o;
	output wire [31:0] alu_operand_a_ex_o;
	output wire [31:0] alu_operand_b_ex_o;
	output wire mult_en_ex_o;
	output wire div_en_ex_o;
	output wire [1:0] multdiv_operator_ex_o;
	output wire [1:0] multdiv_signed_mode_ex_o;
	output wire [31:0] multdiv_operand_a_ex_o;
	output wire [31:0] multdiv_operand_b_ex_o;
	output wire csr_access_o;
	output wire [1:0] csr_op_o;
	output wire csr_save_if_o;
	output wire csr_save_id_o;
	output wire csr_restore_mret_id_o;
	output wire csr_restore_dret_id_o;
	output wire csr_save_cause_o;
	output wire [31:0] csr_mtval_o;
	input [1:0] priv_mode_i;
	input wire csr_mstatus_tw_i;
	input wire illegal_csr_insn_i;
	output wire data_req_ex_o;
	output wire data_we_ex_o;
	output wire [1:0] data_type_ex_o;
	output wire data_sign_ext_ex_o;
	output wire [31:0] data_wdata_ex_o;
	input wire lsu_addr_incr_req_i;
	input wire [31:0] lsu_addr_last_i;
	input wire csr_mstatus_mie_i;
	input wire csr_msip_i;
	input wire csr_mtip_i;
	input wire csr_meip_i;
	input wire [14:0] csr_mfip_i;
	input wire irq_pending_i;
	input wire irq_nm_i;
	input wire lsu_load_err_i;
	input wire lsu_store_err_i;
	output wire debug_mode_o;
	output wire [2:0] debug_cause_o;
	output wire debug_csr_save_o;
	input wire debug_req_i;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	input wire [31:0] regfile_wdata_lsu_i;
	input wire [31:0] regfile_wdata_ex_i;
	input wire [31:0] csr_rdata_i;
	output wire [4:0] rfvi_reg_raddr_ra_o;
	output wire [31:0] rfvi_reg_rdata_ra_o;
	output wire [4:0] rfvi_reg_raddr_rb_o;
	output wire [31:0] rfvi_reg_rdata_rb_o;
	output wire [4:0] rfvi_reg_waddr_rd_o;
	output wire [31:0] rfvi_reg_wdata_rd_o;
	output wire rfvi_reg_we_o;
	output wire perf_jump_o;
	output reg perf_branch_o;
	output wire perf_tbranch_o;
	output reg instr_ret_o;
	output wire instr_ret_compressed_o;
	`include "ibex_pkg.v"
	wire illegal_insn_dec;
	wire ebrk_insn;
	wire mret_insn_dec;
	wire dret_insn_dec;
	wire ecall_insn_dec;
	wire wfi_insn_dec;
	wire branch_in_dec;
	reg branch_set_n;
	reg branch_set_q;
	wire jump_in_dec;
	wire jump_set;
	wire instr_executing;
	wire instr_multicycle;
	reg instr_multicycle_done_n;
	reg instr_multicycle_done_q;
	reg stall_lsu;
	reg stall_multdiv;
	reg stall_branch;
	reg stall_jump;
	wire [31:0] imm_i_type;
	wire [31:0] imm_s_type;
	wire [31:0] imm_b_type;
	wire [31:0] imm_u_type;
	wire [31:0] imm_j_type;
	wire [31:0] zimm_rs1_type;
	wire [31:0] imm_a;
	reg [31:0] imm_b;
	wire [4:0] regfile_raddr_a;
	wire [4:0] regfile_raddr_b;
	wire [4:0] regfile_waddr;
	wire [31:0] regfile_rdata_a;
	wire [31:0] regfile_rdata_b;
	reg [31:0] regfile_wdata;
	wire [1:0] regfile_wdata_sel;
	wire regfile_we;
	reg regfile_we_wb;
	wire regfile_we_dec;
	wire [4:0] alu_operator;
	wire [1:0] alu_op_a_mux_sel;
	wire [1:0] alu_op_a_mux_sel_dec;
	wire alu_op_b_mux_sel;
	wire alu_op_b_mux_sel_dec;
	wire imm_a_mux_sel;
	wire [2:0] imm_b_mux_sel;
	wire [2:0] imm_b_mux_sel_dec;
	wire mult_en_id;
	wire mult_en_dec;
	wire div_en_id;
	wire div_en_dec;
	wire multdiv_en_dec;
	wire [1:0] multdiv_operator;
	wire [1:0] multdiv_signed_mode;
	wire data_we_id;
	wire [1:0] data_type_id;
	wire data_sign_ext_id;
	wire data_req_id;
	wire data_req_dec;
	wire csr_pipe_flush;
	reg [31:0] alu_operand_a;
	wire [31:0] alu_operand_b;
	assign alu_op_a_mux_sel = (fault_inj1(lsu_addr_incr_req_i,1,1) ? fault_inj2(OP_A_FWD,2,3) : fault_inj2(alu_op_a_mux_sel_dec,4,5));

	assign alu_op_b_mux_sel = (fault_inj1(lsu_addr_incr_req_i,6,6) ? fault_inj1(OP_B_IMM,7,7) : fault_inj1(alu_op_b_mux_sel_dec,8,8));

	assign imm_b_mux_sel = (fault_inj1(lsu_addr_incr_req_i,9,9) ? fault_inj3(IMM_B_INCR_ADDR,10,12) : fault_inj3(imm_b_mux_sel_dec,13,15));
    
	assign imm_a = ((fault_inj1(imm_a_mux_sel,16,16) == fault_inj1(IMM_A_Z,17,17)) ? fault_inj32(zimm_rs1_type,18,49) : fault_inj32(1'b0,50,81));

	always @(*) begin : alu_operand_a_mux
		case (fault_inj2(alu_op_a_mux_sel,82,83))
			OP_A_REG_A: alu_operand_a = fault_inj32(regfile_rdata_a,84,115);
			OP_A_FWD: alu_operand_a = fault_inj32(lsu_addr_last_i,116,147);
			OP_A_CURRPC: alu_operand_a = fault_inj32(pc_id_i,148,179);
			OP_A_IMM: alu_operand_a = fault_inj32(imm_a,180,211);
			default: alu_operand_a = 1'bX;
		endcase
	end
	always @(*) begin : immediate_b_mux
		case (fault_inj3(imm_b_mux_sel,212,214))
			IMM_B_I: imm_b = fault_inj32(imm_i_type,215,246);
			IMM_B_S: imm_b = fault_inj32(imm_s_type,247,278);
			IMM_B_B: imm_b = fault_inj32(imm_b_type,279,310);
			IMM_B_U: imm_b = fault_inj32(imm_u_type,311,342);
			IMM_B_J: imm_b = fault_inj32(imm_j_type,343,374);
			IMM_B_INCR_PC: imm_b = (fault_inj1(instr_is_compressed_i,375,375) ? fault_inj32(32'h2,376,407) : fault_inj32(32'h4,408,439));
			IMM_B_INCR_ADDR: imm_b = fault_inj32(32'h4,440,471);
			default: imm_b = 1'bX;
		endcase
	end
	assign alu_operand_b = ((fault_inj1(alu_op_b_mux_sel,472,472) == fault_inj1(OP_B_IMM,473,473)) ? fault_inj32(imm_b,474,505) : fault_inj32(regfile_rdata_b,506,537));
	assign regfile_we = ((fault_inj1(illegal_csr_insn_i,538,538) || !fault_inj1(instr_executing,539,539)) ? 1'b0 : ((fault_inj1(data_req_dec,540,540) || fault_inj1(multdiv_en_dec,541,541)) ? fault_inj1(regfile_we_wb,542,542) : fault_inj1(regfile_we_dec,543,543)));
	always @(*) begin : regfile_wdata_mux
		case (fault_inj2(regfile_wdata_sel,544,545))
			RF_WD_EX: regfile_wdata = fault_inj32(regfile_wdata_ex_i,546,577);
			RF_WD_LSU: regfile_wdata = fault_inj32(regfile_wdata_lsu_i,578,609);
			RF_WD_CSR: regfile_wdata = fault_inj32(csr_rdata_i,610,641);
			default: regfile_wdata = 1'bX;
		endcase
	end
	ibex_register_file #(.RV32E(RV32E)) registers_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.raddr_a_i(regfile_raddr_a),
		.rdata_a_o(regfile_rdata_a),
		.raddr_b_i(regfile_raddr_b),
		.rdata_b_o(regfile_rdata_b),
		.waddr_a_i(regfile_waddr),
		.wdata_a_i(regfile_wdata),
		.we_a_i(regfile_we)
	);
	assign rfvi_reg_raddr_ra_o = fault_inj5(regfile_raddr_a,642,646);
	assign rfvi_reg_rdata_ra_o = fault_inj32(regfile_rdata_a,647,678);
	assign rfvi_reg_raddr_rb_o = fault_inj5(regfile_raddr_b,679,683);
	assign rfvi_reg_rdata_rb_o = fault_inj32(regfile_rdata_b,684,715);
	assign rfvi_reg_waddr_rd_o = fault_inj5(regfile_waddr,716,720);
	assign rfvi_reg_wdata_rd_o = fault_inj32(regfile_wdata,721,752);
	assign rfvi_reg_we_o = fault_inj1(regfile_we,753,753);
	ibex_decoder #(
		.RV32E(RV32E),
		.RV32M(RV32M)
	) decoder_i(
		.illegal_insn_o(illegal_insn_dec),
		.ebrk_insn_o(ebrk_insn),
		.mret_insn_o(mret_insn_dec),
		.dret_insn_o(dret_insn_dec),
		.ecall_insn_o(ecall_insn_dec),
		.wfi_insn_o(wfi_insn_dec),
		.jump_set_o(jump_set),
		.instr_new_i(instr_new_i),
		.instr_rdata_i(instr_rdata_i),
		.illegal_c_insn_i(illegal_c_insn_i),
		.imm_a_mux_sel_o(imm_a_mux_sel),
		.imm_b_mux_sel_o(imm_b_mux_sel_dec),
		.imm_i_type_o(imm_i_type),
		.imm_s_type_o(imm_s_type),
		.imm_b_type_o(imm_b_type),
		.imm_u_type_o(imm_u_type),
		.imm_j_type_o(imm_j_type),
		.zimm_rs1_type_o(zimm_rs1_type),
		.regfile_wdata_sel_o(regfile_wdata_sel),
		.regfile_we_o(regfile_we_dec),
		.regfile_raddr_a_o(regfile_raddr_a),
		.regfile_raddr_b_o(regfile_raddr_b),
		.regfile_waddr_o(regfile_waddr),
		.alu_operator_o(alu_operator),
		.alu_op_a_mux_sel_o(alu_op_a_mux_sel_dec),
		.alu_op_b_mux_sel_o(alu_op_b_mux_sel_dec),
		.mult_en_o(mult_en_dec),
		.div_en_o(div_en_dec),
		.multdiv_operator_o(multdiv_operator),
		.multdiv_signed_mode_o(multdiv_signed_mode),
		.csr_access_o(csr_access_o),
		.csr_op_o(csr_op_o),
		.csr_pipe_flush_o(csr_pipe_flush),
		.data_req_o(data_req_dec),
		.data_we_o(data_we_id),
		.data_type_o(data_type_id),
		.data_sign_extension_o(data_sign_ext_id),
		.jump_in_dec_o(jump_in_dec),
		.branch_in_dec_o(branch_in_dec)
	);
	assign illegal_insn_o = (fault_inj1(instr_valid_i,754,754) & (fault_inj1(illegal_insn_dec,755,755) | fault_inj1(illegal_csr_insn_i,756,756)));
	ibex_controller controller_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.fetch_enable_i(fetch_enable_i),
		.ctrl_busy_o(ctrl_busy_o),
		.illegal_insn_i(illegal_insn_o),
		.ecall_insn_i(ecall_insn_dec),
		.mret_insn_i(mret_insn_dec),
		.dret_insn_i(dret_insn_dec),
		.wfi_insn_i(wfi_insn_dec),
		.ebrk_insn_i(ebrk_insn),
		.csr_pipe_flush_i(csr_pipe_flush),
		.instr_valid_i(instr_valid_i),
		.instr_i(instr_rdata_i),
		.instr_compressed_i(instr_rdata_c_i),
		.instr_is_compressed_i(instr_is_compressed_i),
		.instr_fetch_err_i(instr_fetch_err_i),
		.pc_id_i(pc_id_i),
		.instr_valid_clear_o(instr_valid_clear_o),
		.id_in_ready_o(id_in_ready_o),
		.instr_req_o(instr_req_o),
		.pc_set_o(pc_set_o),
		.pc_mux_o(pc_mux_o),
		.exc_pc_mux_o(exc_pc_mux_o),
		.exc_cause_o(exc_cause_o),
		.lsu_addr_last_i(lsu_addr_last_i),
		.load_err_i(lsu_load_err_i),
		.store_err_i(lsu_store_err_i),
		.branch_set_i(branch_set_q),
		.jump_set_i(jump_set),
		.csr_mstatus_mie_i(csr_mstatus_mie_i),
		.csr_msip_i(csr_msip_i),
		.csr_mtip_i(csr_mtip_i),
		.csr_meip_i(csr_meip_i),
		.csr_mfip_i(csr_mfip_i),
		.irq_pending_i(irq_pending_i),
		.irq_nm_i(irq_nm_i),
		.csr_save_if_o(csr_save_if_o),
		.csr_save_id_o(csr_save_id_o),
		.csr_restore_mret_id_o(csr_restore_mret_id_o),
		.csr_restore_dret_id_o(csr_restore_dret_id_o),
		.csr_save_cause_o(csr_save_cause_o),
		.csr_mtval_o(csr_mtval_o),
		.priv_mode_i(priv_mode_i),
		.csr_mstatus_tw_i(csr_mstatus_tw_i),
		.debug_mode_o(debug_mode_o),
		.debug_cause_o(debug_cause_o),
		.debug_csr_save_o(debug_csr_save_o),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step_i),
		.debug_ebreakm_i(debug_ebreakm_i),
		.debug_ebreaku_i(debug_ebreaku_i),
		.stall_lsu_i(stall_lsu),
		.stall_multdiv_i(stall_multdiv),
		.stall_jump_i(stall_jump),
		.stall_branch_i(stall_branch),
		.perf_jump_o(perf_jump_o),
		.perf_tbranch_o(perf_tbranch_o)
	);
	assign multdiv_en_dec = (fault_inj1(mult_en_dec,757,757) | fault_inj1(div_en_dec,758,758));
	assign instr_multicycle = (((fault_inj1(data_req_dec,759,759) | fault_inj1(multdiv_en_dec,760,760)) | fault_inj1(branch_in_dec,761,761)) | fault_inj1(jump_in_dec,762,762));
	assign instr_executing = ((fault_inj1(instr_new_i,763,763) | (fault_inj1(instr_multicycle,764,764) & ~fault_inj1(instr_multicycle_done_q,765,765))) & ~fault_inj1(instr_fetch_err_i,766,766));
	assign data_req_id = (fault_inj1(instr_executing,767,767) ? fault_inj1(data_req_dec,768,768) : 1'b0);
	assign mult_en_id = (fault_inj1(instr_executing,769,769) ? fault_inj1(mult_en_dec,770,770) : 1'b0);
	assign div_en_id = (fault_inj1(instr_executing,771,771) ? fault_inj1(div_en_dec,772,772) : 1'b0);
	assign data_req_ex_o = fault_inj1(data_req_id,773,773);
	assign data_we_ex_o = fault_inj1(data_we_id,774,774);
	assign data_type_ex_o = fault_inj2(data_type_id,775,776);
	assign data_sign_ext_ex_o = fault_inj1(data_sign_ext_id,777,777);
	assign data_wdata_ex_o = fault_inj32(regfile_rdata_b,778,809);
	assign alu_operator_ex_o = fault_inj5(alu_operator,810,814);
	assign alu_operand_a_ex_o = fault_inj32(alu_operand_a,815,846);
	assign alu_operand_b_ex_o = fault_inj32(alu_operand_b,847,878);
	assign mult_en_ex_o = fault_inj1(mult_en_id,879,879);
	assign div_en_ex_o = fault_inj1(div_en_id,880,880);
	assign multdiv_operator_ex_o = fault_inj2(multdiv_operator,881,882);
	assign multdiv_signed_mode_ex_o = fault_inj2(multdiv_signed_mode,883,884);
	assign multdiv_operand_a_ex_o = fault_inj32(regfile_rdata_a,885,916);
	assign multdiv_operand_b_ex_o = fault_inj32(regfile_rdata_b,917,948);
	reg [0:0] id_wb_fsm_cs;
	reg [0:0] id_wb_fsm_ns;
	always @(posedge clk_i or negedge rst_ni) begin : id_wb_pipeline_reg
		if (!fault_inj1(rst_ni,949,949)) begin
			id_wb_fsm_cs <= fault_inj1(IDLE,950,950);
			branch_set_q <= fault_inj1(1'b0,951,951);
			instr_multicycle_done_q <= fault_inj1(1'b0,952,952);
		end
		else begin
			id_wb_fsm_cs <= fault_inj1(id_wb_fsm_ns,953,953);
			branch_set_q <= fault_inj1(branch_set_n,954,954);
			instr_multicycle_done_q <= fault_inj1(instr_multicycle_done_n,955,955);
		end
	end
	always @(*) begin : id_wb_fsm
		id_wb_fsm_ns = fault_inj1(id_wb_fsm_cs,956,956);
		instr_multicycle_done_n = fault_inj1(instr_multicycle_done_q,957,957);
		regfile_we_wb = fault_inj1(1'b0,958,958);
		stall_lsu = fault_inj1(1'b0,959,959);
		stall_multdiv = fault_inj1(1'b0,960,960);
		stall_jump = fault_inj1(1'b0,961,961);
		stall_branch = fault_inj1(1'b0,962,962);
		branch_set_n = fault_inj1(1'b0,963,963);
		perf_branch_o = fault_inj1(1'b0,964,964);
		instr_ret_o = fault_inj1(1'b0,965,965);
		case (fault_inj1(id_wb_fsm_cs,966,966))
			IDLE:
				if ((fault_inj1(instr_new_i,967,967) & ~fault_inj1(instr_fetch_err_i,968,968)))
					case (1'b1)
						data_req_dec: begin
							id_wb_fsm_ns = fault_inj1(WAIT_MULTICYCLE,969,969);
							stall_lsu = fault_inj1(1'b1,970,970);
							instr_multicycle_done_n = fault_inj1(1'b0,971,971);
						end
						multdiv_en_dec: begin
							id_wb_fsm_ns = fault_inj1(WAIT_MULTICYCLE,972,972);
							stall_multdiv = fault_inj1(1'b1,973,973);
							instr_multicycle_done_n = fault_inj1(1'b0,974,974);
						end
						branch_in_dec: begin
							id_wb_fsm_ns = (fault_inj1(branch_decision_i,975,975) ? fault_inj1(WAIT_MULTICYCLE,976,976) : fault_inj1(IDLE,977,977));
							stall_branch = fault_inj1(branch_decision_i,978,978);
							instr_multicycle_done_n = ~fault_inj1(branch_decision_i,979,979);
							branch_set_n = fault_inj1(branch_decision_i,980,980);
							perf_branch_o = fault_inj1(1'b1,981,981);
							instr_ret_o = ~fault_inj1(branch_decision_i,982,982);
						end
						jump_in_dec: begin
							id_wb_fsm_ns = fault_inj1(WAIT_MULTICYCLE,983,983);
							stall_jump = fault_inj1(1'b1,984,984);
							instr_multicycle_done_n = fault_inj1(1'b0,985,985);
						end
						default: begin
						instr_multicycle_done_n = fault_inj1(1'b0,986,986);
						instr_ret_o = fault_inj1(1'b1,987,987);
					end
					endcase
			WAIT_MULTICYCLE:
				if (((fault_inj1(data_req_dec,988,988) & fault_inj1(lsu_valid_i,989,989)) | (~fault_inj1(data_req_dec,990,990) & fault_inj1(ex_valid_i,991,991)))) begin
					id_wb_fsm_ns = fault_inj1(IDLE,992,992);
					instr_multicycle_done_n = fault_inj1(1'b1,993,993);
					regfile_we_wb = (fault_inj1(regfile_we_dec,994,994) & ~fault_inj1(lsu_load_err_i,995,995));
					instr_ret_o = fault_inj1(1'b1,996,996);
				end
				else begin
					stall_lsu = fault_inj1(data_req_dec,997,997);
					stall_multdiv = fault_inj1(multdiv_en_dec,998,998);
					stall_branch = fault_inj1(branch_in_dec,999,999);
					stall_jump = fault_inj1(jump_in_dec,1000,1000);
				end
			default: id_wb_fsm_ns = 1'bX;
		endcase
	end
	assign instr_ret_compressed_o = (fault_inj1(instr_ret_o,1001,1001) & fault_inj1(instr_is_compressed_i,1002,1002));
endmodule
