//FROZEN NO CHANGES

`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12.10.2024 08:43:01
// Design Name:
// Module Name: mat
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module accelerator(

    input clk,
    input rst,

    input start,
    output done,

    input valid_in,
    output ready_in,

    input [511:0] input_vector,

    output valid_out,
    input ready_out,

    output [511:0] output_vector
);
        assign output_vector = 512'hDEADBEEF;
        assign done = start;
endmodule
