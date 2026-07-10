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
	// input 		external_reset,
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
	output  [31:0] MM_Addr_in,
	output  [31:0]dest_addr_dcmem,
	input  sel_mat,
	input [31:0] j,
	input stall_vector,
	output  [BIT_WIDTH*8 - 1:0] datMem_512_in,
	input [BIT_WIDTH*8 - 1:0] datMem_512_out,
	input memRW_mat,//what is this not used anywhere
	input stall_program,
	output reg scalar_mem_valid,
	output reg scalar_mem_write,
	output reg [31:0] scalar_mem_addr,
	output reg [31:0] scalar_mem_wdata,
	input [31:0] scalar_mem_rdata,
	input scalar_mem_ready,//not used anywhere
	output [31:0] pcUpd_1,
	output [31:0] progCnt_1,
	output [31:0] immData_1,
	output [31:0] regData1_1,
	output [31:0] regData2_1,
	output [31:0] aluIn1_1,
	output [31:0] aluIn2_1,
	output [31:0] aluOut_1,
	output [31:0] datOut_1,
	output [31:0] retOut_1,
	output [31:0] progAdd_1
	);

	wire	[31:0]	inst;
	wire		brEQ;
	wire		brLT;
	wire		brGE;

	reg	[2:0]	stg = 3'b111; //pipeline counter 7->0->1->2->3->4->0

	reg	[31:0]	pcNext;
	reg	[31:0]	wData;
	wire atom_reserved;
	wire [31:0] atom_csr_Address;


	wire	[31:0]	pcUpd,pcUpd_1;
	wire	[31:0]	progCnt,progCnt_1;
	wire	[31:0]	immData,immData_1;
	wire	[31:0]	regData1,regData1_1;
	wire	[31:0]	regData2,regData2_1;
	wire	[31:0]	aluIn1,aluIn1_1;
	wire	[31:0]	aluIn2,aluIn2_1;
	wire	[31:0]	aluOut,aluOut_1;
	wire	[31:0]	datOut,datOut_1;
	wire	[31:0]	retOut,retOut_1;
	wire	[31:0]	progAdd,progAdd_1;
	assign aluIn1_1 = aluIn1;
	assign aluIn2_1 = aluIn2;
	assign progCnt_1 = progCnt;
	assign immData_1 = immData;
	assign regData1_1 = regData1;
	assign regData2_1 = regData2;
	assign aluOut_1 = aluOut;
	assign datOut_1 = datOut;
	assign retOut_1 = retOut;
	assign progAdd_1 = progAdd;
	assign pcUpd_1 = pcUpd;

	MUX2x1 MUX2x1_pc_dut(
	.clk	(clk),
	.inp1	(progAdd),
	.inp2	(aluOut),
	.sel	(PCSel),
	.out	(pcUpd)
	);

	progCount progCount_dut(
	.clk(clk),
	.rst(rst),
	.stg(stg),
	.pcUpd(pcUpd),
	.progCnt(progCnt)
	);

	add4_v add4_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.addInp	(progCnt),
	.addOut	(progAdd),
	.stall(stall_vector)
	);

	insMemory insMemory_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.progCnt(progCnt),
	.outIns	(inst)
	);

	immGen immGen_dut(
	.clk	(clk),
	.rst	(rst),
	.stg	(stg),
	.insInp	(inst),
	.immSel	(immSel),
	.dataOut(immData)
	);

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

	MUX2x1 MUX2x1_asel_dut(
	.clk	(clk),
	.inp1	(regData1),
	.inp2	(progCnt),
	.sel	(aSel),
	.out	(aluIn1)
	);

	MUX2x1 MUX2x1_bsel_dut(
	.clk	(clk),
	.inp1	(regData2),
	.inp2	(immData),
	.sel	(bSel),
	.out	(aluIn2)
	);

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

	vreg_addr_input vreg_addr_1 (
	.clk(clk),
	.inp1(regData1),
	.inp2(regData2),
	.out1(MM_Addr_in),
	.out2(dest_addr_dcmem),
	.sel(1'b1)
	);


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
                if((stg == 3'd3) && (!stall_vector) && (!stall_program))
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
                if((!stall_vector) && (!stall_program))
                begin
                    if(stg < 3'd4)
                        stg <= stg + 3'd1;
                    else
                        stg <= 3'd0;
                end
            end
        end
        
	endmodule
