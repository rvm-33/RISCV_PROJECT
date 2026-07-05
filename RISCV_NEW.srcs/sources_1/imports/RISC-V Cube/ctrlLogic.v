/* =============================================================================
File        : ctrlLogic.v  [CORE MODULE]
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Generates control signals that manage data flow and operations.
Decodes instruction opcodes to produce outputs aluSel, regWEn, branch etc seen in datapath diagram.

**** Implement instructions extensions using cases visible in ctrlLogic and the .xlsx file.
**** Click CTRL+F and search instrcutions easily like "ADD", "VMUL" etc.
Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/

`timescale 1ns/10ps
module ctrlLogic(
	input		clk,
	input		rst,
	input	[31:0]	inst, 
	input		brEQ,
	input		brLT,
	input		brGE,
	output	reg	PCSel,  
	output	reg	immSel,
	output	reg	regWEn,
	output	reg	brUn,
	output	reg	aSel,
	output	reg	bSel,
	
	output	reg [4:0]	aluSel,
	output	reg	memRW,
	output	reg [1:0]	wbSel,
	//VECTOR CORE
	output reg vector_issue,
    output reg [31:0] vector_instr,
    output reg scalar_stall,

    // Completion
    input vector_done
	);

		always @(posedge clk)	begin
		//default inititalization
                PCSel	<= 1'b0;
				immSel	<= 1'b0;
				regWEn	<= 1'b0;
				brUn	<= 1'b0;
				aSel	<= 1'b0;
				bSel	<= 1'b0;
				aluSel	<= 5'b0;
				memRW	<= 1'b0;
				wbSel	<= 2'b0;
			if(rst)begin
				PCSel	<= 1'b0;
				immSel	<= 1'b0;
				regWEn	<= 1'b0;
				brUn	<= 1'b0;
				aSel	<= 1'b0;
				bSel	<= 1'b0;
				aluSel	<= 5'b0;
				memRW	<= 1'b0;
				wbSel	<= 2'b0;
				scalar_stall <=1'b0;
                vector_issue<=1'b0;
                scalar_stall<=1'b0;
			end
        if (scalar_stall) begin
            // Wait until vector execution completes
            if (vector_done) begin
                scalar_stall <= 1'b0;
                vector_issue <= 1'b0;
            end
            else begin
                scalar_stall <= 1'b1;
                vector_issue <= 1'b0;      // one-cycle pulse only
            end
        end
		else begin
				case(inst[6:0])
				    7'b0100111,
				    7'b1010111,
				    7'b0000111:	begin //VECTOR INSTRUCTION
                        vector_issue<=1'b1;
                        vector_instr<=inst;
                        scalar_stall<=1'b1;
				    end
					7'b0010011:	begin /// I-Type Instructions
						case(inst[14:12])
							3'b000:	begin //addi
								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b1;
								brUn	<= 1'b0;
								aSel	<= 1'b0;
								bSel	<= 1'b1;
								aluSel	<= 5'b0;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b010:	begin //slti
								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b1;
								brUn	<= 1'b0;
								aSel	<= 1'b0;
								bSel	<= 1'b1;
								aluSel	<= 5'b1001;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b111:	begin //ANDI

								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b1;
								brUn	<= 1'b0;
								aSel	<= 1'b0;
								bSel	<= 1'b1;
								aluSel	<= 5'b0010;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b110:	begin // ori
								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b1;
								brUn	<= 1'b0;
								aSel	<= 1'b0;
								bSel	<= 1'b1;
								aluSel	<= 5'b0011;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b100:	begin // xori
								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b1;
								brUn	<= 1'b0;
								aSel	<= 1'b0;
								bSel	<= 1'b1;
								aluSel	<= 5'b0100;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b001:	begin
								case(inst[31:25])
									7'b0000000:	begin //slli
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b1;
										aluSel	<= 5'b0110;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
								endcase
							end
							3'b101:	begin
								case(inst[31:25])
									7'b0000000:	begin //srli
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b1;
										aluSel	<= 5'b0111;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0100000:	begin //srai
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b1;
										aluSel	<= 5'b1000;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
								endcase
							end
						endcase
					end
					7'b0110111:	begin //lui
						PCSel	<= 1'b0;
						immSel	<= 1'b1;
						regWEn	<= 1'b1;
						brUn	<= 1'b0;
						aSel	<= 1'b0;
						bSel	<= 1'b1;
						aluSel	<= 5'b0010;
						memRW	<= 1'b0;
						wbSel	<= 2'b1;
					end
					7'b0010111:	begin //auipc
						PCSel	<= 1'b1;
						immSel	<= 1'b1;
						regWEn	<= 1'b1;
						brUn	<= 1'b0;
						aSel	<= 1'b0;
						bSel	<= 1'b1;
						aluSel	<= 5'b0010;
						memRW	<= 1'b0;
						wbSel	<= 2'b1;
					end
					7'b0110011:	begin //
						case(inst[14:12])
							3'b000:	begin
								case(inst[31:25])
									7'b0000000:	begin //add
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b0;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin //mul
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b01111;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0100000:	begin //sub
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b0001;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin // M Extension
									end
									7'b1000000:	begin
										// CubeRoot

										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b10001;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b1000011:	begin
										// squareRoot

										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b10010;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b1000001:	begin // VSQR
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b10011;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
								endcase
							end
							3'b010:	begin
								case(inst[31:25])
									7'b0000000:	begin //slt
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b1001;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin //sltu
									end
								endcase
							end
							3'b011:	begin // M extension
								case(inst[31:25])
									7'b0000000:	begin
									end
									7'b0000001:	begin
									end
								endcase
							end
							3'b111:	begin
								case(inst[31:25])
									7'b0000000:	begin //and
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b0010;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin // M extension
									end
								endcase
							end
							3'b110:	begin
								case(inst[31:25])
									7'b0000000:	begin //or
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b0011;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin // M extension
									end
								endcase
							end
							3'b100:	begin
								case(inst[31:25])
									7'b0000000:	begin //xor
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b0100;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin //
									end
								endcase
							end
							3'b001:	begin
								case(inst[31:25])
									7'b0000000:	begin //sll
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b0110;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin // M extension
									end
								endcase
							end
							3'b101:	begin
								case(inst[31:25])
									7'b0000000:	begin //srl
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b0111;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0100000:	begin
										PCSel	<= 1'b0;
										immSel	<= 1'b1;
										regWEn	<= 1'b1;
										brUn	<= 1'b0;
										aSel	<= 1'b0;
										bSel	<= 1'b0;
										aluSel	<= 5'b1000;
										memRW	<= 1'b0;
										wbSel	<= 2'b1;
									end
									7'b0000001:	begin // M extension
									end
								endcase
							end
						endcase
					end
					7'b1101111:	begin // jal
						// Stores rd and jumps to imm value field address
						PCSel	<= 1'b1;
						immSel	<= 1'b1;
						regWEn	<= 1'b1;
						brUn	<= 1'b0;
						aSel	<= 1'b1;
						bSel	<= 1'b1;
						aluSel	<= 5'b0;
						memRW	<= 1'b0;
						wbSel	<= 2'b1;
					end

					7'b1100111:	begin //jalr
						case(inst[14:12])
							3'b000:	begin
								PCSel 	<= 1'b1;
								immSel	<= 1'b1;
								regWEn	<= 1'b1;
								brUn	<= 1'b0;
								aSel	<= 1'b0;
								bSel	<= 1'b1;
								aluSel	<= 5'b0;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
						endcase
					end
					7'b1100011:	begin
						case(inst[14:12])
							3'b000:	begin   /// Branch if Equal (BEQ)
								if	(brEQ == 1'b1)
								PCSel	<= 1'b1;
							else if	(brEQ == 1'b0)
								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b0;
								brUn	<= 1'b1;
								aSel	<= 1'b1;  // Ins
								bSel	<= 1'b1;	 // Imm
								aluSel	<= 5'b0;  // ADD
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b001:	begin  //branch if not equal
								if	(brEQ == 1'b0)
								PCSel	<= 1'b1;
							else if	(brEQ == 1'b1)
								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b0;
								brUn	<= 1'b1;
								aSel	<= 1'b1;
								bSel	<= 1'b1;
								aluSel	<= 5'b0;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b100:	begin //blt
								if	(brLT == 1'b1)
								PCSel	<= 1'b1;
							else if	(brLT == 1'b0)
								PCSel	<= 1'b0;
								immSel	<= 1'b1;
								regWEn	<= 1'b0;
								brUn	<= 1'b1;
								aSel	<= 1'b1;
								bSel	<= 1'b1;
								aluSel	<= 5'b0;
								memRW	<= 1'b0;
								wbSel	<= 2'b1;
							end
							3'b110:	begin //bltu
								if	(brLT == 1'b0)
								PCSel	<=1'b1;
							else if	(brLT ==1'b1)
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b0;
								brUn	<=1'b1;
								aSel	<=1'b0;
								bSel	<=1'b0;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b1;
							end
							3'b101:	begin //bge
								if	(brGE ==1'b1)
								PCSel	<=1'b1;
							else if	(brGE ==1'b0)
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b0;
								brUn	<=1'b1;
								aSel	<=1'b1;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b1;
							end
							3'b111:	begin //bgeu
								if	(brGE ==1'b0)
								PCSel	<=1'b1;
							else if	(brGE ==1'b1)
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b0;
								brUn	<=1'b1;
								aSel	<=1'b0;
								bSel	<=1'b0;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b1;
							end
						endcase
					end
					7'b0000011:	begin
						case(inst[14:12])
							3'b000:	begin // Load Byte
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b1;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b0;
							end
							3'b001:	begin //LH
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b1;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b0;
							end
							3'b100:	begin //LBU
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b1;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b0;
							end
							3'b110:	begin //
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b1;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b0;
							end
							3'b101:	begin //LHU
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b1;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b0;
							end
							3'b111:	begin
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b1;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b0;
								wbSel	<=2'b0;
							end
						endcase
					end
					7'b0100011:	begin //S TYPE
						case(inst[14:12])
							3'b000:	begin //SB
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b0;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b1;
								wbSel	<=2'b0;
							end
							3'b001:	begin//SH
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b0;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b1;
								wbSel	<=2'b0;
							end
							3'b010:	begin//SW
								PCSel	<=1'b0;
								immSel	<=1'b1;
								regWEn	<=1'b0;
								brUn	<=1'b0;
								aSel	<=1'b0;
								bSel	<=1'b1;
								aluSel	<=5'b0;
								memRW	<=1'b1;
								wbSel	<=2'b0;
							end
						endcase
					end
					7'b0001111:	begin // Memory ordering
						case(inst[14:12])
							3'b000:	begin
							end
							3'b001:	begin
							end
							3'b010:	begin
							end
						endcase
					end
					7'b1110011:	begin //ENVIRONMENT CALL AND BREAKPOINTS
						case(inst[14:12])
							3'b000:	begin // Environment calls and breakpoints
								case(inst[31:20])
									12'b000000000000:	begin
									end
									12'b000000000001:	begin
									end
								endcase
							end
							3'b001:	begin // Atomic operations
							end
							3'b010:	begin
							end
							3'b011:	begin
							end
							3'b101:	begin
							end
							3'b110:	begin
							end
							3'b111:	begin
							end
						endcase
					end
					7'b0101111:	begin //ATOMIC MEMORY OPERATIONS
						case(inst[14:12])
							3'b100:	begin
								case(inst[31:27])
									5'b00010:	begin
										PCSel	<=1'b0;
										immSel	<=1'b0;
										regWEn	<=1'b1;
										brUn	<=1'b0;
										aSel	<=1'b0;
										bSel	<=1'b0;
										aluSel	<=5'b0;
										memRW	<=1'b0;
										wbSel	<=2'b0;
										// Load-Reserved
									end
									// 						5'b10000:	begin // Atomic operations
										// 						end
									endcase
								end
								3'b110:	begin
									case(inst[31:27])
										5'b00011:	begin // Store-Conditional
											PCSel	<=1'b0;
											immSel	<=1'b0;
											regWEn	<=1'b0;
											brUn	<=1'b0;
											aSel	<=1'b0;
											bSel	<=1'b0;
											aluSel	<=5'b10101;
											memRW	<=1'b1;
											wbSel	<=2'b0;
										end
										// 						5'b11000:	begin // Atomic operations
											// 						end
										endcase
									end
									3'b010:	begin // Atomic operations
										case(inst[31:27])
											5'b00001:	begin
											end
											5'b01100:	begin
											end
										endcase
									end
									3'b000:	begin // Atomic operations
										case(inst[31:27])
											5'b00000:	begin
											end
										endcase
									end
									3'b011:	begin // Atomic operations
										case(inst[31:27])
											5'b01000:	begin
											end
										endcase
									end
									3'b001:	begin // Atomic operations
										case(inst[31:27])
											5'b00100:	begin
											end
										endcase
									end
									3'b101:	begin // Atomic operations
										case(inst[31:27])
											5'b10100:	begin
											end
										endcase
									end
									3'b111:	begin // Atomic operations
										case(inst[31:27])
											5'b11100:	begin
											end
										endcase
									end
								endcase
							end
							7'b1000011:	begin // F extension //FMADD
							end
							7'b1000111:	begin // F extension //FMSUB
							end
							7'b1001011:	begin // F extension //FNMSUB
							end
							7'b1001111:	begin // F extension //FNMADD
							end
							7'b1010011:	begin // F extension
								case(inst[14:12]) ///rm bit
									3'b111: begin
										case(inst[31:25]) //funct7
											7'b0001000:	begin //FMUL
												//// Floating Point Multiplication  FMUL
												PCSel	<=1'b0;
												immSel	<=1'b1;
												regWEn	<=1'b1;
												brUn	<=1'b0;
												aSel	<=1'b0;
												bSel	<=1'b0;
												aluSel	<=5'b11111;
												memRW	<=1'b0;
												wbSel	<=2'b1;
											end
											7'b0001001:	begin //FVMUL
												//// Vedic Floating Point Multiplication  FVMUL
												PCSel	<=1'b0;
												immSel	<=1'b1;
												regWEn	<=1'b1;
												brUn	<=1'b0;
												aSel	<=1'b0;
												bSel	<=1'b0;
												aluSel	<=5'b11110;
												memRW	<=1'b0;
												wbSel	<=2'b1;
											end
											7'b0001011:	begin //FVDIV
												//// Vedic Floating Point Multiplication  FVMUL
												PCSel	<=1'b0;
												immSel	<=1'b1;
												regWEn	<=1'b1;
												brUn	<=1'b0;
												aSel	<=1'b0;
												bSel	<=1'b0;
												aluSel	<=5'b11011;
												memRW	<=1'b0;
												wbSel	<=2'b1;
											end
											7'b0000111:	begin //IEEEDIV
												////
												PCSel	<=1'b0;
												immSel	<=1'b1;
												regWEn	<=1'b1;
												brUn	<=1'b0;
												aSel	<=1'b0;
												bSel	<=1'b0;
												aluSel	<=5'b01011;
												memRW	<=1'b0;
												wbSel	<=2'b1;
											end
										endcase

									end
								endcase
							end
							7'b0001011:	begin
								case(inst[14:12])
									3'b000: begin
										PCSel	<=1'b0;
										immSel<=1'b1;
										regWEn<=1'b1;
										brUn	<=1'b0;
										aSel	<=1'b0;
										bSel	<=1'b1;
										aluSel<=5'b10000;
										memRW	<=1'b0;
										wbSel	<=2'b1;
									end
								endcase
							end
						endcase
					end
				end

			endmodule
