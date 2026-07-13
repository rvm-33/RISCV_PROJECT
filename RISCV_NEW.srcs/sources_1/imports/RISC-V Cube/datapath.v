/* =============================================================================
File        : datapath.v  [CORE MODULE]
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Implements both the RISC-V and Vector datapath as shown in riscv-datapath.png and vector-datapath.png

Authors     :
Naveen Kollepara : ec21b1030@iiitdm.ac.in
Vashist Managari : ec21b1038@iiitdm.ac.in

Tools       :
gtkwave, iverilog, vivado, nclaunch
=============================================================================
*/

`timescale 1ns/10ps
module datapath#(parameter BIT_WIDTH = 8)(
	input		clk,
	input		rst,
	input		PCSel,
	input		immSel,
	input		regWEn,
	input		brUn,
	input		aSel,
	input		bSel,
	input	[4:0]	aluSel,
	input		memRW,
	input	[1:0]	wbSel,
	output	 [31:0]	inst,
	output		brEQ,
	output		brLT,
	output		brGE,
	input stall_vector,//vector stall
	
	output reg scalar_mem_valid,
	output reg scalar_mem_write,
	output reg [31:0] scalar_mem_addr,
	output reg [31:0] scalar_mem_wdata,
	input [31:0] scalar_mem_rdata
	);

	wire	[31:0]	inst;
	wire		brEQ;
	wire		brLT;
	wire		brGE;
	reg	[2:0]	stg = 3'b111; //pipeline counter 7->0->1->2->3->4->0
	reg	[31:0]	wData;
	wire atom_reserved;
	wire [31:0] atom_csr_Address;
	wire	[31:0]	pcUpd;
	wire	[31:0]	progCnt;
	wire	[31:0]	immData;
	wire	[31:0]	regData1;
	wire	[31:0]	regData2;
	wire	[31:0]	aluIn1;
	wire	[31:0]	aluIn2;
	wire	[31:0]	aluOut;
	wire	[31:0]	datOut;
	wire	[31:0]	retOut;
	wire	[31:0]	progAdd;
	(* DONT_TOUCH = "TRUE" *)

	MUX2x1 MUX2x1_pc_dut(
	.clk	(clk),
	.inp1	(progAdd),
	.inp2	(aluOut),
	.sel	(PCSel),
	.out	(pcUpd)
	);
	(* DONT_TOUCH = "TRUE" *)

	progCount progCount_dut(
	.clk(clk),
	.rst(rst),
	.stg(stg),
	.pcUpd(pcUpd),
	.progCnt(progCnt)
	);
	(* DONT_TOUCH = "TRUE" *)

	add4_v add4_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.addInp	(progCnt),
	.addOut	(progAdd),
	.stall(stall_vector)
	);
	(* DONT_TOUCH = "TRUE" *)

	insMemory insMemory_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.progCnt(progCnt),
	.outIns	(inst)
	);
	(* DONT_TOUCH = "TRUE" *)

	immGen immGen_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.insInp	(inst),
	.immSel	(immSel),
	.dataOut(immData)
	);
	(* DONT_TOUCH = "TRUE" *)

	regFile regFile_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.RegWEn	(regWEn),
	.wData	(retOut),
	.dReg	(inst[11:07]),
	.sReg1	(inst[19:15]),
	.sReg2	(inst[24:20]),
	.sData1	(regData1),
	.sData2	(regData2),
	.stall(stall_vector)
	);
	(* DONT_TOUCH = "TRUE" *)

	jump jump_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.data1	(regData1),
	.data2	(regData2),
	.brUn	(brUn),
	.brEQ	(brEQ),
	.brLT	(brLT),
	.brGE	(brGE)
	);
	(* DONT_TOUCH = "TRUE" *)

	MUX2x1 MUX2x1_asel_dut(
	.clk	(clk),
	.inp1	(regData1),
	.inp2	(progCnt),
	.sel	(aSel),
	.out	(aluIn1)
	);
	(* DONT_TOUCH = "TRUE" *)

	MUX2x1 MUX2x1_bsel_dut(
	.clk	(clk),
	.inp1	(regData2),
	.inp2	(immData),
	.sel	(bSel),
	.out	(aluIn2)
	);
	(* DONT_TOUCH = "TRUE" *)

	alu alu_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.inData1(aluIn1),
	.inData2(aluIn2),
	.aluSel	(aluSel),
	.aluOut	(aluOut)
	);

	assign datOut = scalar_mem_rdata;

	(* DONT_TOUCH = "TRUE" *)

	MUX4x1	MUX4x1_dut(
	.clk	(clk),
	.inp1	(datOut),
	.inp2	(aluOut),
	.inp3	(progAdd),
	.inp4	(32'b0),
	.sel	(wbSel),
	.out	(retOut)
	);

	//  atom atom_dut(
	//    .clk(clk),
	//    .instruction(inst),
	//    .data1(regData1),
	//    .reserved(atom_reserved),
	//    .csr_address(atom_csr_Address)
	//  );

    always @(posedge clk or posedge rst)
        begin
            if(rst)
            begin
                scalar_mem_valid <= 1'b0;
                scalar_mem_write <= 1'b0;
                scalar_mem_addr  <= 32'b0;
                scalar_mem_wdata <= 32'b0;
            end
            else
            begin
                // Default
                scalar_mem_valid <= 1'b0;
                scalar_mem_write <= 1'b0;
        
                // Memory stage only
                if((stg == 3'd3) && (!stall_vector))
                begin
                    scalar_mem_valid <= 1'b1;
                    scalar_mem_addr  <= aluOut;
                    if(memRW)
                    begin
                        // Store
                        scalar_mem_write <= 1'b1;
                        scalar_mem_wdata <= regData2;
                    end
                    else
                    begin
                        // Load
                        scalar_mem_write <= 1'b0;
                    end
                end
            end
        end

	// initial	begin
		// 	stg <= 3'b111;
		// end
        
        always @(negedge clk or posedge rst)
        begin
            if(rst)
                stg <= 3'b111;
            else
            begin
                if((!stall_vector))
                begin
                    if(stg < 3'd4)
                        stg <= stg + 3'd1;
                    else
                        stg <= 3'd0;
                end
            end
        end
        
	endmodule
