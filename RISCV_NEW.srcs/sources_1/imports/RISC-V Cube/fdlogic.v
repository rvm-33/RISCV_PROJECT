/* =============================================================================
File        : fdlogic.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
fdlogic.v
This module is used to act like a mux for directing the data to be written from the register file to the MMU.
It is instantiated in the datapath module.
It acts like a state machine to control the data transfer from the register file to the MMU.
Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/






`timescale 1ns/10ps

module fdlogic#(parameter BIT_WIDTH = 8)(input begin_transfer,
	input [9:0]matrix_type,
	input [BIT_WIDTH*8 - 1:0]rddata_512,
	output reg [8:0]register_loc_begin,
	output reg [BIT_WIDTH*8 - 1:0]wrdata_512,
	output reg internal_reset_to_vec_mult,
	input clk
	);

	reg [4:0]state;

	always@(posedge clk)begin
		if(begin_transfer == 1'b1)begin
			if(matrix_type == 10'd64)begin
				case(state)
					5'd0:begin
						register_loc_begin <= 10'd1;
						internal_reset_to_vec_mult <= 1'b1;
						state <= 5'd1;
					end
					5'd1:begin
						//           register_loc_begin <= 10'd0;
						internal_reset_to_vec_mult <= 1'b0;
						wrdata_512 <= rddata_512;
						state <= 5'd2;
					end
					5'd2:begin
						register_loc_begin <= 10'd1;
						state <= 5'd3;
					end

					5'd3:begin
						state <= 5'd4;
						//           register_loc_begin <= 10'd1;
						wrdata_512 <= rddata_512;
					end
					5'd4:begin
						state <= 5'd5;
						register_loc_begin <= 10'd2;
					end
					5'd5:begin
						state <= 5'd6;
						register_loc_begin <= 10'd2;
						wrdata_512 <= rddata_512;
					end
					5'd6:begin
						state <= 5'd7;
						register_loc_begin <= 10'd3;
					end
					5'd7:begin
						state <= 5'd8;
						//           register_loc_begin <= 10'd3;
						wrdata_512 <= rddata_512;
					end
					5'd8:begin
						//           state <= 5'd9;
						//           r/egister_loc_begin <= 32'd2;
						//           wrdata_512 <= rddata_512;

					end
				endcase
			end
		end
	else if(begin_transfer == 1'd0)begin
			state <= 5'd0;
			register_loc_begin <= 10'd0;
		end

	end

endmodule


