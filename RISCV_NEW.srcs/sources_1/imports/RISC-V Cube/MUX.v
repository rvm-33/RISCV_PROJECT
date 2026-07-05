`timescale 1ns/10ps
module MUX2x1 (
	input		clk,
	input	[31:0] 	inp1,
	input	[31:0]	inp2,
	input 		sel,
	output	[31:0]	out
	);

	reg [31:0] out;

	always @ (clk)	begin
		case(sel)
			1'b0:	out <= inp1;
			1'b1:	out <= inp2;
		endcase
	end

endmodule
module MUX2x1_v (
	input		clk,
	input	[511:0] 	inp1,
	input	[511:0]	inp2,
	input 		sel,
	output	[511:0]	out
	);

	reg [511:0] out;

	always @ (clk)	begin
		case(sel)
			1'b0:	out <= inp1;
			1'b1:	out <= inp2;
		endcase
	end

endmodule
module MUX4x1 (
	input		clk,
	input   [31:0] 	inp1,
	input   [31:0]	inp2,
	input   [31:0]	inp3,
	input	[31:0]	inp4,
	input 	[1:0]	sel,
	output	[31:0]	out
	);

	reg [31:0] out;

	always @ (clk) begin
		case (sel)
			2'b00:	out <= inp1;
			2'b01:	out <= inp2;
			2'b10:	out <= inp3;
			2'b11:	out <= inp4;
		endcase
	end

endmodule
