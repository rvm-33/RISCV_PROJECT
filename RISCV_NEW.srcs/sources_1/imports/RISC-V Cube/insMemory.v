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

		// Load program
		$readmemh("C:\\Users\\rvmri\\Downloads\\RISC_RVV\\CODES\\assembler\\output.txt", insMem);

		//    for(i = 0; i < 16; i = i + 1)
		//        $display("insMem[%0d] = %h", i, insMem[i]);

	end

	// Instruction Fetch
	always @(negedge clk) begin

		if(stg == 3'b000) begin

			outIns <= insMem[progCnt >> 2];

			//        $display(
			//            "TIME=%0t PC=%0d INDEX=%0d INST=%h",
			//            $time,
			//            progCnt,
			//            progCnt >> 2,
			//            insMem[progCnt >> 2]
			//        );

		end

	end

endmodule