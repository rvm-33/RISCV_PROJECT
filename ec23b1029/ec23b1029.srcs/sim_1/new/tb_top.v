`timescale 1ns/1ps

module tb_top;

reg clk;
reg rst;

//-------------------------------------
// DUT
//-------------------------------------
top dut
(
    .clk(clk),
    .rst(rst)
);

//-------------------------------------
// Clock Generation (100 MHz)
//-------------------------------------
always #5 clk = ~clk;

//-------------------------------------
// Stimulus
//-------------------------------------
initial
begin

    clk = 1'b0;
    rst = 1'b1;

    // Hold reset for a few cycles
    #20;
    rst = 1'b0;

    // Run long enough for:
    // VLOAD -> DCT -> VSTORE
    #3000;

    $finish;

end

//-------------------------------------
// Waveform Dump
//-------------------------------------
initial
begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
end

endmodule