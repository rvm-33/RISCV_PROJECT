`timescale 1ns / 1ps

module config_unit(
    input clk,
    input rst,
    input start,
    output reg done,
    output [31:0] vl,
    output [2:0] sew,
    output vm
);

assign vl = 32'd16;
assign sew = 3'd2; // Encoded SEW = 32
assign vm = 1'b1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        done <= 1'b0;
    end else begin
        done <= start;
    end
end

endmodule
