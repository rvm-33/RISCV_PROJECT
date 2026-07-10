/* =============================================================================
File        : add4_v.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
If stg register (keeps track of the RISC-V pipelins stage) is 3,
Adds 4 to the data in addInp and outputs addOut
Also stalls the RISC-V pipeline operation with stall register

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/

`timescale 1ns/10ps
module add4_v(
	input		clk,
	input		rst,
	input	[2:0]	stg,
	input stall,
	input	[31:0] addInp,
	output	reg [31:0] addOut
	);

	// reg	[31:0] addOut;

	always @(negedge clk)	begin
		if (stg == 3'b011)	begin
			if(stall != 1'b1)begin
				addOut <= addInp + 3'b100;
			end
		else begin
				// do nothing
			end
		end



	end

endmodule
