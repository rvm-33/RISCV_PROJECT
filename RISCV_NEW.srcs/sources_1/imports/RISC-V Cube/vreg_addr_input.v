/* =============================================================================
File        : vreg_addr_input.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
vreg_addr_input.v
This module is used to act like a mux for directing the data to be written from the register file to the MMU.
It is instantiated in the datapath module.

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/



`timescale 1ns/10ps
module vreg_addr_input(

	input		clk,
	input   [31:0] 	inp1,
	input   [31:0]	inp2,
	// input   [31:0]	inp3,
	// input	[31:0]	inp4,
	input 	sel,
	output	reg [31:0]	out1,
	output	reg [31:0]	out2
	// output	reg [31:0]	out3
	// output	[31:0]	out1,

	);

	// reg [31:0] out;

	always @ (clk) begin
		if(sel == 1'b1) begin
			out1 <= inp1;
			out2 <= inp2;
			// out3 <= inp3;
			// 2'b11:	out4 <= inp4;
		end
	end

endmodule
