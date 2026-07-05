/* =============================================================================
File        : full_adder_rtl.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Generic full adder

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/
module full_adder (A, B, C_in, C_out, Clock, SUM);
	input [3:0] A, B;
	input Clock, C_in;
	output reg [3:0] SUM;
	output reg C_out;

	reg [3:0] reg1, reg2, sum_i;
	reg c_in, c_out;

	always @ (posedge Clock)
	begin
		reg1 <= A;
		reg2 <= B;
		c_in <= C_in;
	end

	always @ (posedge Clock)
	begin
		SUM <= sum_i;
		C_out <= c_out;
	end

	always @ *
	begin
		{c_out, sum_i} = reg1 + reg2 + c_in;
	end

endmodule
