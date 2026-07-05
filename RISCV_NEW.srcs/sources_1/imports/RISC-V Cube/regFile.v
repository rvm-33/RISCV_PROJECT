/* =============================================================================
File        : regfile.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Register File
This module is used to implement the register file in the RISC-V Vector Vedic Core.
It is a 32x32 register file. The module is designed to work with a 32-bit address bus.
It takes data from the ALU and writes it to the register file. The module is designed
to work with a 32-bit data bus. The module is designed to work with a 32-bit data bus.
It has all the functionalities similar to normal register file.
The module is designed to work with a 32-bit data bus. The module is designed to work
with a 32-bit address bus. The module is designed to work with a 32-bit data bus.

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/

`timescale 1ns/10ps
module regFile(
	input 		clk,
	input		rst,
	input	[2:0]	stg,
	input		RegWEn,
	input	[31:0]	wData,
	input	[4:0]	dReg,
	input	[4:0]	sReg1,
	input	[4:0]	sReg2,
	output [31:0]	sData1,
	output [31:0]	sData2,
	input stall
	);

	reg	[31:0]	regArray [31:0];

	reg	[31:0]	reg00;
	reg	[31:0]	reg01;
	reg	[31:0]	reg02;
	reg	[31:0]	reg03;
	reg	[31:0]	reg04;
	reg	[31:0]	reg05;
	reg	[31:0]	reg06;
	reg	[31:0]	reg07;
	reg	[31:0]	reg08;
	reg	[31:0]	reg09;
	reg	[31:0]	reg10;
	reg	[31:0]	reg11;
	reg	[31:0]	reg12;
	reg	[31:0]	reg13;
	reg	[31:0]	reg14;
	reg	[31:0]	reg15;
	reg	[31:0]	reg16;
	reg	[31:0]	reg17;
	reg	[31:0]	reg18;
	reg	[31:0]	reg19;
	reg	[31:0]	reg20;
	reg	[31:0]	reg21;
	reg	[31:0]	reg22;
	reg	[31:0]	reg23;
	reg	[31:0]	reg24;
	reg	[31:0]	reg25;
	reg	[31:0]	reg26;
	reg	[31:0]	reg27;
	reg	[31:0]	reg28;
	reg	[31:0]	reg29;
	reg	[31:0]	reg30;
	reg	[31:0]	reg31;

	wire	[31:0]	rdAddr1;
	wire	[31:0]	rdAddr2;
	wire	[31:0]	wrAddr;

	// integer 	rdFile;
	// integer		readFile;
	// integer		wrFile;

	// integer		rdIndex = 0;
	// integer		wrIndex	= 0;

	//always @(clk)	begin
		//	rdFile = $fopen("reg.txt","r");
		//	rdIndex = 0;
		//	while(!$feof(rdFile)) begin
			//		readFile = $fscanf(rdFile,"%b\n",regArray[rdIndex]);
			//		rdIndex = rdIndex + 1;
			//	end
			//	$fclose(rdFile);

			//end

			deCode deCode_dut_R1(
			.clk(clk),
			.dataInp(sReg1),
			.dataOut(rdAddr1)
			);

			deCode deCode_dut_R2(
			.clk(clk),
			.dataInp(sReg2),
			.dataOut(rdAddr2)
			);

			deCode deCode_dut_W(
			.clk(clk),
			.dataInp(dReg),
			.dataOut(wrAddr)
			);

			regSel regSel_dut_1(
			.clk(clk),
			.stg(stg),
			.dataInp(rdAddr1),
			.reg00(reg00),.reg01(reg01),.reg02(reg02),.reg03(reg03),.reg04(reg04),.reg05(reg05),.reg06(reg06),.reg07(reg07),
			.reg08(reg08),.reg09(reg09),.reg10(reg10),.reg11(reg11),.reg12(reg12),.reg13(reg13),.reg14(reg14),.reg15(reg15),
			.reg16(reg16),.reg17(reg17),.reg18(reg18),.reg19(reg19),.reg20(reg20),.reg21(reg21),.reg22(reg22),.reg23(reg23),
			.reg24(reg24),.reg25(reg25),.reg26(reg26),.reg27(reg27),.reg28(reg28),.reg29(reg29),.reg30(reg30),.reg31(reg31),
			.dataOut(sData1),
			.stall_internal(stall)
			);

			regSel regSel_dut_2(
			.clk(clk),
			.stg(stg),
			.dataInp(rdAddr2),
			.reg00(reg00),.reg01(reg01),.reg02(reg02),.reg03(reg03),.reg04(reg04),.reg05(reg05),.reg06(reg06),.reg07(reg07),
			.reg08(reg08),.reg09(reg09),.reg10(reg10),.reg11(reg11),.reg12(reg12),.reg13(reg13),.reg14(reg14),.reg15(reg15),
			.reg16(reg16),.reg17(reg17),.reg18(reg18),.reg19(reg19),.reg20(reg20),.reg21(reg21),.reg22(reg22),.reg23(reg23),
			.reg24(reg24),.reg25(reg25),.reg26(reg26),.reg27(reg27),.reg28(reg28),.reg29(reg29),.reg30(reg30),.reg31(reg31),
			.dataOut(sData2),
			.stall_internal(stall)
			);

			always @(posedge clk)	begin
				if(rst) begin
					reg00 <= 32'h0;
					reg01 <= 32'd4;
					reg02 <= 32'd1;
					reg03 <= 32'd2;
					reg04 <= 32'd3;
					reg05 <= 32'd4;
					reg06 <= 32'd3;
					reg07 <= 32'd5;
					reg08 <= 32'd7;
					reg09 <= 32'd11;
					reg10 <= 32'h00000400;
					reg11 <= 32'h00000800;
					reg12 <= 32'h0000000A;
					reg13 <= 32'h00002000;
					reg14 <= 32'h00004000;
					reg15 <= 32'h00008000;
					reg16 <= 32'h00010000;
					reg17 <= 32'h00020000;
					reg18 <= 32'h00040000;
					reg19 <= 32'h00080000;
					reg20 <= 32'h00100000;
					reg21 <= 32'h00200000;
					reg22 <= 32'h00400000;
					reg23 <= 32'h00800000;
					reg24 <= 32'h01000000;
					reg25 <= 32'h02000000;
					reg26 <= 32'h04000000;
					reg27 <= 32'h08000000;
					reg28 <= 32'h10000000;
					reg29 <= 32'h20000000;
					reg30 <= 32'h40000000;
					reg31 <= 32'h80000000;
				end
			else if (stg == 3'b100)	begin
					if (RegWEn == 1)	begin

						case (wrAddr)
							32'b0000_0000_0000_0000_0000_0000_0000_0010: reg01 <= wData;
							32'b0000_0000_0000_0000_0000_0000_0000_0100: reg02 <= wData;
							32'b0000_0000_0000_0000_0000_0000_0000_1000: reg03 <= wData;
							32'b0000_0000_0000_0000_0000_0000_0001_0000: reg04 <= wData;
							32'b0000_0000_0000_0000_0000_0000_0010_0000: reg05 <= wData;
							32'b0000_0000_0000_0000_0000_0000_0100_0000: reg06 <= wData;
							32'b0000_0000_0000_0000_0000_0000_1000_0000: reg07 <= wData;
							32'b0000_0000_0000_0000_0000_0001_0000_0000: reg08 <= wData;
							32'b0000_0000_0000_0000_0000_0010_0000_0000: reg09 <= wData;
							32'b0000_0000_0000_0000_0000_0100_0000_0000: reg10 <= wData;
							32'b0000_0000_0000_0000_0000_1000_0000_0000: reg11 <= wData;
							32'b0000_0000_0000_0000_0001_0000_0000_0000: reg12 <= wData;
							32'b0000_0000_0000_0000_0010_0000_0000_0000: reg13 <= wData;
							32'b0000_0000_0000_0000_0100_0000_0000_0000: reg14 <= wData;
							32'b0000_0000_0000_0000_1000_0000_0000_0000: reg15 <= wData;
							32'b0000_0000_0000_0001_0000_0000_0000_0000: reg16 <= wData;
							32'b0000_0000_0000_0010_0000_0000_0000_0000: reg17 <= wData;
							32'b0000_0000_0000_0100_0000_0000_0000_0000: reg18 <= wData;
							32'b0000_0000_0000_1000_0000_0000_0000_0000: reg19 <= wData;
							32'b0000_0000_0001_0000_0000_0000_0000_0000: reg20 <= wData;
							32'b0000_0000_0010_0000_0000_0000_0000_0000: reg21 <= wData;
							32'b0000_0000_0100_0000_0000_0000_0000_0000: reg22 <= wData;
							32'b0000_0000_1000_0000_0000_0000_0000_0000: reg23 <= wData;
							32'b0000_0001_0000_0000_0000_0000_0000_0000: reg24 <= wData;
							32'b0000_0010_0000_0000_0000_0000_0000_0000: reg25 <= wData;
							32'b0000_0100_0000_0000_0000_0000_0000_0000: reg26 <= wData;
							32'b0000_1000_0000_0000_0000_0000_0000_0000: reg27 <= wData;
							32'b0001_0000_0000_0000_0000_0000_0000_0000: reg28 <= wData;
							32'b0010_0000_0000_0000_0000_0000_0000_0000: reg29 <= wData;
							32'b0100_0000_0000_0000_0000_0000_0000_0000: reg30 <= wData;
							32'b1000_0000_0000_0000_0000_0000_0000_0000: reg31 <= wData;
						endcase

						regArray[0]	<= reg00;
						regArray[1]	<= reg01;
						regArray[2]	<= reg02;
						regArray[3]	<= reg03;
						regArray[4]	<= reg04;
						regArray[5]	<= reg05;
						regArray[6]	<= reg06;
						regArray[7]	<= reg07;
						regArray[8]	<= reg08;
						regArray[9]	<= reg09;
						regArray[10]	<= reg10;
						regArray[11]	<= reg11;
						regArray[12]	<= reg12;
						regArray[13]	<= reg13;
						regArray[14]	<= reg14;
						regArray[15]	<= reg15;
						regArray[16]	<= reg16;
						regArray[17]	<= reg17;
						regArray[18]	<= reg18;
						regArray[19]	<= reg19;
						regArray[20]	<= reg20;
						regArray[21]	<= reg21;
						regArray[22]	<= reg22;
						regArray[23]	<= reg23;
						regArray[24]	<= reg24;
						regArray[25]	<= reg25;
						regArray[26]	<= reg26;
						regArray[27]	<= reg27;
						regArray[28]	<= reg28;
						regArray[29]	<= reg29;
						regArray[30]	<= reg30;
						regArray[31]	<= reg31;
						/*
						wrFile = $fopen("reg.txt","w");
						for(wrIndex = 0; wrIndex <32; wrIndex = wrIndex + 1)	begin
							$fwrite(wrFile,"%b\n",regArray[wrIndex]);
						end
						$fclose(wrFile);*/
					end
				end
			end

		endmodule

		module deCode(
	input		clk,
	input	[4:0]	dataInp,
	output	reg [31:0]	dataOut
	);


			always @(dataInp)	begin
				case(dataInp)
					5'b00000: dataOut <= 32'b0000_0000_0000_0000_0000_0000_0000_0001;
					5'b00001: dataOut <= 32'b0000_0000_0000_0000_0000_0000_0000_0010;
					5'b00010: dataOut <= 32'b0000_0000_0000_0000_0000_0000_0000_0100;
					5'b00011: dataOut <= 32'b0000_0000_0000_0000_0000_0000_0000_1000;
					5'b00100: dataOut <= 32'b0000_0000_0000_0000_0000_0000_0001_0000;
					5'b00101: dataOut <= 32'b0000_0000_0000_0000_0000_0000_0010_0000;
					5'b00110: dataOut <= 32'b0000_0000_0000_0000_0000_0000_0100_0000;
					5'b00111: dataOut <= 32'b0000_0000_0000_0000_0000_0000_1000_0000;
					5'b01000: dataOut <= 32'b0000_0000_0000_0000_0000_0001_0000_0000;
					5'b01001: dataOut <= 32'b0000_0000_0000_0000_0000_0010_0000_0000;
					5'b01010: dataOut <= 32'b0000_0000_0000_0000_0000_0100_0000_0000;
					5'b01011: dataOut <= 32'b0000_0000_0000_0000_0000_1000_0000_0000;
					5'b01100: dataOut <= 32'b0000_0000_0000_0000_0001_0000_0000_0000;
					5'b01101: dataOut <= 32'b0000_0000_0000_0000_0010_0000_0000_0000;
					5'b01110: dataOut <= 32'b0000_0000_0000_0000_0100_0000_0000_0000;
					5'b01111: dataOut <= 32'b0000_0000_0000_0000_1000_0000_0000_0000;
					5'b10000: dataOut <= 32'b0000_0000_0000_0001_0000_0000_0000_0000;
					5'b10001: dataOut <= 32'b0000_0000_0000_0010_0000_0000_0000_0000;
					5'b10010: dataOut <= 32'b0000_0000_0000_0100_0000_0000_0000_0000;
					5'b10011: dataOut <= 32'b0000_0000_0000_1000_0000_0000_0000_0000;
					5'b10100: dataOut <= 32'b0000_0000_0001_0000_0000_0000_0000_0000;
					5'b10101: dataOut <= 32'b0000_0000_0010_0000_0000_0000_0000_0000;
					5'b10110: dataOut <= 32'b0000_0000_0100_0000_0000_0000_0000_0000;
					5'b10111: dataOut <= 32'b0000_0000_1000_0000_0000_0000_0000_0000;
					5'b11000: dataOut <= 32'b0000_0001_0000_0000_0000_0000_0000_0000;
					5'b11001: dataOut <= 32'b0000_0010_0000_0000_0000_0000_0000_0000;
					5'b11010: dataOut <= 32'b0000_0100_0000_0000_0000_0000_0000_0000;
					5'b11011: dataOut <= 32'b0000_1000_0000_0000_0000_0000_0000_0000;
					5'b11100: dataOut <= 32'b0001_0000_0000_0000_0000_0000_0000_0000;
					5'b11101: dataOut <= 32'b0010_0000_0000_0000_0000_0000_0000_0000;
					5'b11110: dataOut <= 32'b0100_0000_0000_0000_0000_0000_0000_0000;
					5'b11111: dataOut <= 32'b1000_0000_0000_0000_0000_0000_0000_0000;
				endcase
			end

		endmodule

		module regSel(
	input		clk,
	input	[2:0]	stg,
	input	[31:0]	dataInp,
	input	[31:0]	reg00,
	input	[31:0]	reg01,
	input	[31:0]	reg02,
	input	[31:0]	reg03,
	input	[31:0]	reg04,
	input	[31:0]	reg05,
	input	[31:0]	reg06,
	input	[31:0]	reg07,
	input	[31:0]	reg08,
	input	[31:0]	reg09,
	input	[31:0]	reg10,
	input	[31:0]	reg11,
	input	[31:0]	reg12,
	input	[31:0]	reg13,
	input	[31:0]	reg14,
	input	[31:0]	reg15,
	input	[31:0]	reg16,
	input	[31:0]	reg17,
	input	[31:0]	reg18,
	input	[31:0]	reg19,
	input	[31:0]	reg20,
	input	[31:0]	reg21,
	input	[31:0]	reg22,
	input	[31:0]	reg23,
	input	[31:0]	reg24,
	input	[31:0]	reg25,
	input	[31:0]	reg26,
	input	[31:0]	reg27,
	input	[31:0]	reg28,
	input	[31:0]	reg29,
	input	[31:0]	reg30,
	input	[31:0]	reg31,
	output	reg 	[31:0]	dataOut,
	input 	stall_internal
	);

			always @(negedge clk)	begin
				if (stg == 3'b001 || stall_internal == 1'b1)	begin
					case(dataInp)
						32'b0000_0000_0000_0000_0000_0000_0000_0001: dataOut <= reg00;
						32'b0000_0000_0000_0000_0000_0000_0000_0010: dataOut <= reg01;
						32'b0000_0000_0000_0000_0000_0000_0000_0100: dataOut <= reg02;
						32'b0000_0000_0000_0000_0000_0000_0000_1000: dataOut <= reg03;
						32'b0000_0000_0000_0000_0000_0000_0001_0000: dataOut <= reg04;
						32'b0000_0000_0000_0000_0000_0000_0010_0000: dataOut <= reg05;
						32'b0000_0000_0000_0000_0000_0000_0100_0000: dataOut <= reg06;
						32'b0000_0000_0000_0000_0000_0000_1000_0000: dataOut <= reg07;
						32'b0000_0000_0000_0000_0000_0001_0000_0000: dataOut <= reg08;
						32'b0000_0000_0000_0000_0000_0010_0000_0000: dataOut <= reg09;
						32'b0000_0000_0000_0000_0000_0100_0000_0000: dataOut <= reg10;
						32'b0000_0000_0000_0000_0000_1000_0000_0000: dataOut <= reg11;
						32'b0000_0000_0000_0000_0001_0000_0000_0000: dataOut <= reg12;
						32'b0000_0000_0000_0000_0010_0000_0000_0000: dataOut <= reg13;
						32'b0000_0000_0000_0000_0100_0000_0000_0000: dataOut <= reg14;
						32'b0000_0000_0000_0000_1000_0000_0000_0000: dataOut <= reg15;
						32'b0000_0000_0000_0001_0000_0000_0000_0000: dataOut <= reg16;
						32'b0000_0000_0000_0010_0000_0000_0000_0000: dataOut <= reg17;
						32'b0000_0000_0000_0100_0000_0000_0000_0000: dataOut <= reg18;
						32'b0000_0000_0000_1000_0000_0000_0000_0000: dataOut <= reg19;
						32'b0000_0000_0001_0000_0000_0000_0000_0000: dataOut <= reg20;
						32'b0000_0000_0010_0000_0000_0000_0000_0000: dataOut <= reg21;
						32'b0000_0000_0100_0000_0000_0000_0000_0000: dataOut <= reg22;
						32'b0000_0000_1000_0000_0000_0000_0000_0000: dataOut <= reg23;
						32'b0000_0001_0000_0000_0000_0000_0000_0000: dataOut <= reg24;
						32'b0000_0010_0000_0000_0000_0000_0000_0000: dataOut <= reg25;
						32'b0000_0100_0000_0000_0000_0000_0000_0000: dataOut <= reg26;
						32'b0000_1000_0000_0000_0000_0000_0000_0000: dataOut <= reg27;
						32'b0001_0000_0000_0000_0000_0000_0000_0000: dataOut <= reg28;
						32'b0010_0000_0000_0000_0000_0000_0000_0000: dataOut <= reg29;
						32'b0100_0000_0000_0000_0000_0000_0000_0000: dataOut <= reg30;
						32'b1000_0000_0000_0000_0000_0000_0000_0000: dataOut <= reg31;
					endcase
				end
			end

		endmodule
