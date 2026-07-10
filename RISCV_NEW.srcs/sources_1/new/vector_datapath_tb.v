`timescale 1ns/1ps

`include "../imports/RISC-V Cube/vector_datapath.v"
`include "../imports/RISC-V Cube/datMemory.v"
`include "../imports/RISC-V Cube/vregfile.v"
`include "../imports/RISC-V Cube/vec_mult.v"
`include "../new/vector_decoder.v"
`include "../new/vector_controller.v"
`include "../new/config_unit.v"
`include "../new/vlsu.v"
`include "../new/mem_arbiter.v"

module vector_datapath_tb;

    reg clk;
    reg rst;
    reg [31:0] instr;
    reg [31:0] base_addr;
    reg begin_var;

    wire stall_vector;
    wire memRW_mat;
    wire [31:0] j;
    wire sel_mat;
    wire [63:0] datMem_512_out;

    vector_datapath #(.BIT_WIDTH(8)) dut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .base_addr(base_addr),
        .begin_var(begin_var),
        .stall_vector(stall_vector),
        .memRW_mat(memRW_mat),
        .j(j),
        .sel_mat(sel_mat),
        .datMem_512_out(datMem_512_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("vector_datapath_tb.vcd");
        $dumpvars(0, vector_datapath_tb);

        rst = 1;
        instr = 32'h00000000;
        base_addr = 32'h1000;
        begin_var = 0;

        repeat (3) @(posedge clk);
        rst = 0;

        // Vector load opcode: 7'b0000111
        // This exercises the decoder -> controller -> VLSU -> VRF path.
        instr = 32'h00000007;
        begin_var = 1'b1;

        repeat (20) @(posedge clk);

        $display("time=%0t stall_vector=%b memRW_mat=%b j=0x%0h", $time, stall_vector, memRW_mat, j);
        $display("time=%0t datMem_512_out=0x%0h", $time, datMem_512_out);

        $finish;
    end
endmodule
