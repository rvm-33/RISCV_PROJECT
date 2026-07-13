`timescale 1ns/10ps

module insMemory (

	input         clk,
	input         rst,
	input  [2:0]  stg,
	input  [31:0] progCnt,
	output reg [31:0] outIns

	);

	reg [31:0] insMem [0:255];

	integer i;

	// Load instructions once at simulation start
	initial begin

		// Optional: clear memory
		for(i = 0; i < 256; i = i + 1)
		insMem[i] = 32'h00000000;

            insMem[0] = 32'h00000007;   // Vector Load
            insMem[1] = 32'h00000000;   // Custom DCT Accelerator
            insMem[2] = 32'h00000027;   // Vector Store

	end

	// Instruction Fetch
	always @(negedge clk) begin

		if(stg == 3'b000) begin

			outIns <= insMem[progCnt >> 2];

		end

	end

endmodule