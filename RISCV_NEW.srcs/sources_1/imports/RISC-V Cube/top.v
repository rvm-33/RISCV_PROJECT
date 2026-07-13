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
	output wire [31:0] inst
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
	wire		brEQ;
	wire		brLT;
	wire		brGE;
	wire stall_vector;
	wire scalar_mem_valid;
	wire scalar_mem_write;
	wire [31:0] scalar_mem_addr;
	wire [31:0] scalar_mem_wdata;
	wire [31:0] scalar_mem_rdata;
	wire scalar_mem_ready;
	wire vector_done;
	wire vector_mem_valid;
	wire vector_mem_write;
	wire [31:0] vector_mem_addr;
	wire [31:0] vector_mem_wdata;
	wire [31:0] vector_mem_rdata;
	wire vector_mem_ready;
	wire stall_program;
    wire [31:0] vector_instr;
	wire vector_issue;
	(* DONT_TOUCH = "TRUE" *)
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
	
	.vector_issue(vector_issue),
	.vector_instr(vector_instr),
	.scalar_stall(stall_vector),
	.vector_done(vector_done)
	);
(* DONT_TOUCH = "TRUE" *)
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
	.scalar_mem_valid(scalar_mem_valid),
	.scalar_mem_write(scalar_mem_write),
	.scalar_mem_addr(scalar_mem_addr),
	.scalar_mem_wdata(scalar_mem_wdata),
	.scalar_mem_rdata(scalar_mem_rdata)
	);
(* DONT_TOUCH = "TRUE" *)
	vector_datapath #(.BIT_WIDTH(BIT_WIDTH)) vector_datapath_dut(
	    .clk(clk),
	    .rst(rst),
	    .vector_valid(vector_issue),
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
(* DONT_TOUCH = "TRUE" *)
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

endmodule
