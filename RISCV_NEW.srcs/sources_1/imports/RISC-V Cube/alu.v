/* =============================================================================
File        : alu.v 		[CORE MODULE]
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Takes inputs
inData1, inData2 from datapath,
and alu_sel from ctrlLogic
and performs respective operations.
**** Add additional cases to implement extensions and vedic instructions.
**** Commented parts are vedic and floating extensions
Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/

`timescale 1ns/10ps
module alu(
	input		clk,
	input		rst,
	input	[2:0]	stg,
	input	[31:0]	inData1,
	input	[31:0]	inData2,
	input	[4:0]	aluSel,
	//   input internal_reset,
	output reg	[31:0]	aluOut
	);
	// reg	[31:0]	aluOut;
	//	wire [127:0] cubeOut;


	//	/// Square Extension
	//	wire [31:0] squareOut;
	//	dwanda32 dwd( .a(inData1), .s(squareOut));

	//  	/// Cube Extension
	//	// cube32bit cube32but_dut(
	//	// 	.a (inData1),
	//	// 	.b (cubeOut)
	//	// );

	//	wire [31:0] fpdout;
	//	wire fpdiv_status;
	//	reg iclk_f),
	//	.rst(internal_reset),
	//	.flpin_A(inData1),
	//	.flpin_B(inData2),
	//	.Q_flp(fpdout),
	//	.completed_flag(fpdiv_status)
	//	);

	//	wire [3:0] cuberoot_b;
	//	wire [5:0] cuberoot_b1;

	//	cuberoot uut (
	//		.a(inData1[11:0]),
	//		.b(cuberoot_b),
	//		.b1(cuberoot_b1)
	//	);

	//	wire [3:0] squareroot_b;
	//	wire [7:0] squareroot_b1;

	// vargamula uut (
	// 	.a(inData1[7:0]),
	// 	.b(squareroot_b),
	// 	.b1(squareroot_b1)
	// );
	//	wire [31:0] ieeeDiv_Out;
	////	div_mod IEEEdivModified_Unit(
	////		.a(inData1), // Dividend
	////		.b(inData2), // Divisor
	////		.result_ieee(ieeeDiv_Out)
	////	);

	//  wire [31:0] fpmout;
	//  fpm fpm_uut(
	//  .a_operand(inData1),
	//  .b_operand(inData2),
	//  .result(fpmout)
	//  );

	//  wire [31:0] fvpmout;
	////   fvpm fvpm_uut(
	//// 	.a_operand(inData1),
	//// 	.b_operand(inData2),
	//// 	.result(fvpmout)
	//// 	);

	//  always @(posedge clk) begin
		//	if(aluSel == 5'b11011) begin
			//		if (stg == 3'b010) begin
				//			internal_reset <= 1'b1;
				//			#1;
				//			internal_reset <= 1'b0;
				//		end
				//	end
				//  end

				always @(negedge clk)	begin
					if (stg == 3'b010)	begin
						case (aluSel)
							5'b00000:	aluOut	<= inData1 + inData2;
							5'b00001:	aluOut	<= inData1 - inData2;
							5'b01111:	aluOut	<= inData1 * inData2;
							5'b00010:	aluOut	<= inData1 & inData2;
							5'b00011:	aluOut	<= inData1 | inData2;
							5'b00100:	aluOut	<= inData1 ^ inData2;
							5'b00110:	aluOut	<= inData1 << inData2;
							5'b00111:	aluOut	<= inData1 >>> inData2;
							5'b01000:	aluOut	<= inData1 >> inData2;
							5'b01001:	begin
								if (inData1 < inData2)	aluOut	<= 32'b1;
							else			aluOut	<= 32'b0;
							end
							//            5'b10000:	aluOut	<= cubeOut;
							//            5'b10101:   aluOut  <= inData1;// for atomic instruction
							//			5'b10010:begin // for squareroot
								//				if(inData2 == 1'b0) aluOut <=  squareroot_b;
								//				else aluOut <= squareroot_b1;
								//			end
								//			5'b10001:begin // for cuberoot
									//				if(inData2 == 1'b0) aluOut <= cuberoot_b;
									//				else aluOut <= cuberoot_b1;
									//			end

									//			// VSQR
									//			5'b10011: aluOut <= squareOut;

									//			// FMUL
									//			5'b11111: aluOut <= fpmout;

									//			// FVMUL
									//			5'b11110: aluOut <= fvpmout;

									//			// FVDIV
									//			5'b11011: aluOut <= fpdout;

									//			5'b01011: aluOut <= ieeeDiv_Out;
									// default: bruh
								endcase
							end
						end

					endmodule
