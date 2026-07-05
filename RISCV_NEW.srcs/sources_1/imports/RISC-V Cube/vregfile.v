//FROZEN

/* =============================================================================
File        : vregfile.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Vector Register File
This module is used to store the vector data. It is a 512-bit register file.
The module is designed to work with a 32-bit address bus. It takes data from MMU and writes it to vector ALU or acceleraotr
You can set the size of each register in MMU. Currently the bus size is 64 bits.
Has all the functionalities similar to normal register file.

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/
`timescale 1ns/10ps

module vregFile
	#(parameter VLEN= 512,REG_COUNT=32)
	(
	input       clk,
	input       rst,
	//write
	input       w_en,
	input [4:0] w_addr01,
	input wire [VLEN-1:0] wdata_512,
	//read
	input [4:0] rd_addr01,
    input [4:0] rd_addr02,
	output reg [VLEN-1:0] rdata_512_01,
	output reg [VLEN-1:0] rdata_512_02
	);

	reg [VLEN-1:0] vector_reg [REG_COUNT-1:0];
     integer i;

	// For writing data into the vector register file
	always @(posedge clk) begin
		if (rst) begin
			// Optionally initialize your registers if needed
			for (i = 0; i < REG_COUNT; i = i + 1) begin
				vector_reg[i] <= {VLEN{1'b1}}; // Reset to 0
			end
			vector_reg[0]<=512'hFFFFFFFF_EEEEEEEE_DDDDDDDD_CCCCCCCC_BBBBBBBB_AAAAAAAA_99999999_88888888_77777777_66666666_55555555_44444444_33333333_22222222_11111111_00000000;
		end
		else if (w_en) begin
				vector_reg[w_addr01] <= wdata_512;
		end
	end

	// For reading data from reg file
	always @(*) begin
		if (rst) begin
			rdata_512_01 <= {VLEN{1'b0}}; // Reset output
			rdata_512_02 <= {VLEN{1'b0}};
		end 
		else begin
			rdata_512_01 <= vector_reg[rd_addr01];
			rdata_512_02 <= vector_reg[rd_addr02];	
		end		
end

endmodule
