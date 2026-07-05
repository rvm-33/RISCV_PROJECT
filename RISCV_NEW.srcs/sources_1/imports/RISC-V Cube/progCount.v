/* =============================================================================
File        : progCount.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Program Counter
Updates program counter based on the RISC-V pipeline stage.
If pipeline reaches final stage (stg == 4) then the PC gets updated as PC = PC + 4

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/


`timescale 1ns/10ps
module progCount(
	input		clk,
	input		rst,
	input	[2:0]	stg,
	input	[31:0]	pcUpd,
	output	[31:0]	progCnt
	);

	reg	[31:0]	progCnt;
	reg	[31:0]	currProg;

	initial	begin
		currProg <= 32'b0;
	end

	always @(posedge clk)	begin
		if (stg == 3'b0)	begin
			progCnt <= currProg;
		end
	end
	always @(negedge clk)	begin
		if(stg == 3'b100)	begin
			currProg <= pcUpd;
		end
	end

endmodule
