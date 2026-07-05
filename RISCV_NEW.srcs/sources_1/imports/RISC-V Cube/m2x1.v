`timescale 1ns/10ps
module m21(
	input wire [8:0]D0,
	input wire [8:0]D1,
	input wire S,
	output reg [8:0]Y
	);
	always @(D0 or D1 or S)
	begin

		if(S)
		Y= D1;
	else
		Y=D0;

	end

endmodule

