/* =============================================================================
File        : immGen.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Used for sign extension

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/

`timescale 1ns/10ps
module immGen(
	input		clk,
	input		rst,
	input	[2:0]	stg,
	input	[31:0]	insInp,
	input		immSel,
	output	[31:0]	dataOut
	);

	reg [31:0] dataOut;

	always @(negedge clk) begin
		if(stg == 3'b001 && immSel) begin
			case(insInp[6:0])
				7'b0010011, 7'b0000011:	begin   /// I-type Instruction
					case(insInp[31])
						1'b1: dataOut <= {20'b11111111111111111111,insInp[31:20]};
						1'b0: dataOut <= {20'b00000000000000000000,insInp[31:20]};
					endcase
					case(insInp[14:12])
						3'b001, 3'b101: dataOut <= {27'b000000000000000000000000000,insInp[24:20]};
					endcase
				end
				7'b0?10111, 7'b1110011:	begin
					case(insInp[31])
						1'b1: dataOut <= {12'b111111111111,insInp[31:12]};
						1'b0: dataOut <= {12'b000000000000,insInp[31:12]};
					endcase
				end
				7'b1101111:	begin // jal
					case(insInp[31])
						1'b1: dataOut <= {11'b11111111111,insInp[31],insInp[19:12],insInp[20],insInp[30:21],1'b0};
						1'b0: dataOut <= {11'b00000000000,insInp[31],insInp[19:12],insInp[20],insInp[30:21],1'b0};
					endcase
				end
				7'b1100111:  /// jalr
				dataOut <= {20'b00000000000000000000,insInp[31:20]};

				//// B-type Instruction
				7'b1100011: begin
					$display("BRANCH");

					$display("inst[31]    = %b", insInp[31]);
					$display("inst[7]     = %b", insInp[7]);
					$display("inst[30:25] = %b", insInp[30:25]);
					$display("inst[11:8]  = %b", insInp[11:8]);

					case(insInp[31])
						1'b1:
						dataOut <= {20'hFFFFF,
						insInp[31],
						insInp[7],
						insInp[30:25],
						insInp[11:8],
						1'b0};

						1'b0:
						dataOut <= {20'h00000,
						insInp[31],
						insInp[7],
						insInp[30:25],
						insInp[11:8],
						1'b0};
					endcase

					$display("BRANCH IMM RAW = %b",
					{insInp[31],
					insInp[7],
					insInp[30:25],
					insInp[11:8],
					1'b0});
				end

				7'b0100011:	begin
					case(insInp[31])
						1'b1: dataOut <= {20'b11111111111111111111,insInp[31:25],insInp[11:7]};
						1'b0: dataOut <= {20'b00000000000000000000,insInp[31:25],insInp[11:7]};
					endcase
				end
				default:	dataOut <= 32'b0;
			endcase
		end
	end

endmodule
