/* =============================================================================
File        : top.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Top module for the RISC-V Vector Vedic Core
This module is used to instantiate all the modules in the design.
Has connections to datapath, vector datapath and control logic.

To run this file, download GTKWAVE and iverilog.
To run the testbench, use the commands in the cmd.tcl:

Correction	:
Should actually include cache in top module, nt iside datapath module


Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/

`timescale 1ns/10ps
// Code your design here
// Code your design here
// Code your design here
//`include "fvdiv.v"
`include "add4_v.v"
`include "alu.v"
//`include "decimalIpIEEEOutdivision.v"
`include "ctrlLogic.v"
// `include "cube.v"
//`include "cuberoot.v"
// `include "squareroot.v"
`include "jump.v"
`include "datapath.v"
`include "datMemory.v"
`include "immGen.v"
`include "insMemory.v"
`include "MUX.v"
//`include "square.v"
`include "progCount.v"
`include "regFile.v"
//`include "atom.v"
//`include "fpm.v"
// `include "fvpm.v"
`include "vreg_addr_input.v"
`include "vec_mult.v"
`include "vregfile.v"
`include "fdlogic.v"
`include "wblogic.v"
`include "m2x1.v"
`include "../../new/vector_decoder.v"
`include "../../new/vector_controller.v"
`include "../../new/config_unit.v"
`include "../../new/vlsu.v"
`include "../../new/mem_arbiter.v"


module top#(parameter BIT_WIDTH = 8)(
	input		clk,
	input		rst,
	output  PCSel_1,
	output  immSel_1,
	output  regWEn_1,
	output  brUn_1,
	output  aSel_1,
	output  bSel_1,
	output  [4:0] aluSel_1,
	output  memRW_1,
	output  [1:0] wbSel_1,
	output  [31:0] inst_1,
	output  brEQ_1,
	output  brLT_1,
	output  brGE_1,
	output wire begin_var_vec_matrix_2,
	output wire controlsig_vec_matrix_2,
	output wire stall_vector_1,
	output wire sel_mat_1,
	output wire memRW_mat_1,
	output wire [31:0] j_1,
	output wire [31:0] MM_Addr_in_1,
	output wire [31:0] dest_addr_dcmem_1,
	output wire [31:0] datMem_512_in_1,
	output wire [31 - 1:0] datMem_512_out_1,
	output  [31:0] pcUpd_1,
	output  [31:0] progCnt_1,
	output  [31:0] immData_1,
	output  [31:0] regData1_1,
	output  [31:0] regData2_1,
	output  [31:0] aluIn1_1,
	output  [31:0] aluIn2_1,
	output  [31:0] aluOut_1,
	output  [31:0] datOut_1,
	output  [31:0] retOut_1,
	output  [31:0] progAdd_1
	);

	wire 		clk_en;
	// assign clk_en = 0;
	wire		PCSel;
	wire		immSel;
	wire		regWEn;
	wire		brUn;
	wire		aSel;
	wire		bSel;
	wire	[4:0]	aluSel;
	wire		memRW;
	wire	[1:0]	wbSel;
	wire	[31:0]	inst;
	wire		brEQ;
	wire		brLT;
	wire		brGE;
	wire begin_var_vec_matrix_1,controlsig_vec_matrix_1,stall_vector,sel_mat,memRW_mat;
	wire [31:0] j;
	wire [31:0] MM_Addr_in,dest_addr_dcmem;
	wire [31 - 1:0] datMem_512_in,datMem_512_out;

	wire vec_valid;
	wire [3:0] vec_op;
	wire [4:0] vd;
	wire [4:0] vs1;
	wire [4:0] vs2;
	wire [4:0] vs3;
	wire [1:0] addr_mode;
	wire [2:0] width;
	wire vm;
	wire [2:0] nf;
	wire [5:0] alu_op;

	wire vlsu_start;
	wire accel_start;
	wire cfg_start;
	wire vlsu_done;
	wire accel_done;
	wire cfg_done;
	wire [31:0] cfg_vl;
	wire [2:0] cfg_sew;
	wire cfg_vm;
	wire co_processor_done;

	wire vrf_w_en;
	wire [4:0] vrf_w_addr;
	wire [511:0] vrf_w_data;
	wire [4:0] vrf_rd_addr01;
	wire [4:0] vrf_rd_addr02;
	wire [511:0] vrf_rdata01;
	wire [511:0] vrf_rdata02;
	wire scalar_mem_valid;
	wire scalar_mem_write;
	wire [31:0] scalar_mem_addr;
	wire [511:0] scalar_mem_wdata;
	wire [511:0] scalar_mem_rdata;
	wire scalar_mem_ready;
	wire vector_done;
	wire vector_mem_valid;
	wire vector_mem_write;
	wire [31:0] vector_mem_addr;
	wire [511:0] vector_mem_wdata;
	wire [511:0] vector_mem_rdata;
	wire vector_mem_ready;
	wire accel_ready_in;
	wire vlsu_cmd_ready;
	wire stall_program_ctrl;
	wire stall_program;
    wire [31:0] vector_instr;
	assign sel_mat = 1'b0;
	assign j = 32'b0;
	assign memRW_mat = vector_mem_write;
	assign stall_program = stall_program_ctrl | stall_vector;
	ctrlLogic ctrlLogic_dut(
	.clk	(clk),
	.rst	(rst),
	.inst	(inst),
	.brEQ	(brEQ),
	.brLT	(brLT),
	.brGE	(brGE),
	.PCSel	(PCSel),
	.immSel	(immSel),
	.regWEn	(regWEn),
	.brUn	(brUn),
	.aSel	(aSel),
	.bSel	(bSel),
	.aluSel	(aluSel),
	.memRW	(memRW),
	.wbSel	(wbSel),
	.vector_issue(begin_var_vec_matrix_1),
	.vector_instr(vector_instr),
	.scalar_stall(stall_scalar),
	.vector_done(vector_done)
	);

	datapath datapath_dut(
	.clk	(clk),
	.rst	(rst),
	.PCSel	(PCSel),
	.immSel	(immSel),
	.regWEn	(regWEn),
	.brUn	(brUn),
	.aSel	(aSel),
	.bSel	(bSel),
	.aluSel	(aluSel),
	.memRW	(memRW),
	.wbSel	(wbSel),
	.inst	(inst),
	.brEQ	(brEQ),
	.brLT	(brLT),
	.brGE	(brGE),
	.stall_vector(stall_vector),
	.stall_program(stall_program),
	.scalar_mem_valid(scalar_mem_valid),
	.scalar_mem_write(scalar_mem_write),
	.scalar_mem_addr(scalar_mem_addr),
	.scalar_mem_wdata(scalar_mem_wdata),
	.scalar_mem_rdata(scalar_mem_rdata),
	.scalar_mem_ready(scalar_mem_ready),
	.pcUpd_1(pcUpd_1),
	.progCnt_1(progCnt_1),
	.immData_1(immData_1),
	.regData1_1(regData1_1),
	.regData2_1(regData2_1),
	.aluIn1_1(aluIn1_1),
	.aluIn2_1(aluIn2_1),
	.aluOut_1(aluOut_1),
	.datOut_1(datOut_1),
	.retOut_1(retOut_1),
	.progAdd_1(progAdd_1)
	);

	vector_datapath #(.BIT_WIDTH(BIT_WIDTH)) vector_datapath_dut(
	    .clk(clk),
	    .rst(rst),
	    .instr(vector_instr),
	    .base_addr(scalar_mem_addr),
	    .memRW_mat(memRW_mat),
	    .vector_done(vector_done),
	    .vector_mem_valid(vector_mem_valid),
	    .vector_mem_write(vector_mem_write),
	    .vector_mem_addr(vector_mem_addr),
	    .vector_mem_wdata(vector_mem_wdata),
	    .vector_mem_ready(vector_mem_ready),
	    .vector_mem_rdata(vector_mem_rdata)
	);

	mem_arbiter #(.VLEN(512)) mem_arbiter_dut(
	    .clk(clk),
	    .rst(rst),
	    .scalar_valid(scalar_mem_valid),
	    .scalar_write(scalar_mem_write),
	    .scalar_addr(scalar_mem_addr),
	    .scalar_wdata(scalar_mem_wdata),
	    .scalar_ready(scalar_mem_ready),
	    .scalar_rdata(scalar_mem_rdata),
	    .vector_valid(vector_mem_valid),
	    .vector_write(vector_mem_write),
	    .vector_addr(vector_mem_addr),
	    .vector_wdata(vector_mem_wdata),
	    .vector_ready(vector_mem_ready),
	    .vector_rdata(vector_mem_rdata)
	);

	//assign stall_vector = 1'b0;
	assign PCSel_1 = PCSel;
	assign immSel_1 = immSel;
	assign regWEn_1 = regWEn;
	assign brUn_1 = brUn;
	assign aSel_1 = aSel;
	assign bSel_1 = bSel;
	assign aluSel_1 = aluSel;
	assign memRW_1 = memRW;
	assign wbSel_1 = wbSel;
	assign inst_1 = inst;
	assign brEQ_1 = brEQ;
	assign brLT_1 = brLT;
	assign brGE_1 = brGE;
	assign j_1 = j;
	assign begin_var_vec_matrix_2 = begin_var_vec_matrix_1;
	assign controlsig_vec_matrix_2 = begin_var_vec_matrix_1;
	assign stall_vector_1 = stall_vector;
	assign sel_mat_1 = sel_mat;
	assign memRW_mat_1 = memRW_mat;
	assign MM_Addr_in_1 = scalar_mem_addr;
	assign dest_addr_dcmem_1 = vector_mem_addr;
	assign datMem_512_in_1 = scalar_mem_wdata[BIT_WIDTH*8-1:0];
	assign datMem_512_out_1 = scalar_mem_rdata[BIT_WIDTH*8-1:0];

endmodule
