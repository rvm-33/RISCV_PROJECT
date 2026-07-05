`timescale 1ns/10ps
module jump(
	input		clk,
	input		rst,
	input	[2:0]	stg,
	input	[31:0]	data1,
	input	[31:0]	data2,
	input		brUn,
	output		brEQ,
	output		brLT,
	output		brGE
	);

	reg brEQ;
	reg brLT;
	reg brGE;

	always @(posedge clk)	begin
		if (stg == 3'b010)	begin
			if (brUn == 1'b1)	begin
				if(data1 == data2)	begin
					brEQ = 1'b1;
					brLT = 1'b0;
					brGE = 1'b0;
				end
			else if(data1 < data2)	begin
					brEQ = 1'b0;
					brLT = 1'b1;
					brGE = 1'b0;
				end
			else if(data1 >= data2)	begin
					brEQ = 1'b0;
					brLT = 1'b0;
					brGE = 1'b1;
				end
			end
		else	begin
				brEQ = 1'b0;
				brLT = 1'b0;
				brGE = 1'b0;
			end
		end
	end

endmodule
