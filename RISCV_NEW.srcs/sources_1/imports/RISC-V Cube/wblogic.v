/* =============================================================================
File        : wblogic.sv
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Acts as an intermediate module to write data to the memory. It takes the input
data from the accelerator and writes it to the memory. This module is instantiated
in vector datapath module.
You can set the size of the bus by changing the parameter BIT_WIDTH. The default value is 8.
Respective control signals are used to control the data flow. The module is designed
to work with a 512-bit bus. The module is designed to work with a 32-bit address bus.

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/
`timescale 1ns/10ps

module wblogic#(parameter BIT_WIDTH = 8)(
	input clk,
	input [BIT_WIDTH*8 - 1:0]in_wrdata_bus,
	input ready_input,
	input complete_input,
	//  input [3:0]witdh_size_in,
	input [31:0]source_addr_dcmem,
	output reg [31:0]dest_addr_dcmem,
	output reg [BIT_WIDTH*8 - 1:0]out_wrdata_bus
	);


	reg [4:0] state_internal;

	always@(posedge clk)begin
		if(ready_input == 1'b1)begin
			if(state_internal == 1'b0)
			out_wrdata_bus <= in_wrdata_bus;
			dest_addr_dcmem <= source_addr_dcmem;
			state_internal <= 1'b1;
		end

		if(state_internal == 1'b1)
		out_wrdata_bus <= in_wrdata_bus;
		dest_addr_dcmem <= source_addr_dcmem + 32'd16;
		state_internal <= 1'b1;
	end


	//    else begin

		//      state_internal <= 1'b0;
		//     out_wrdata_bus <= 512'd0;
		//    dest_addr_dcmem <= 32'd0;
		//    end



	endmodule
