`timescale 1ns/1ps

module tb_vector_datapath;

reg clk;
reg rst;

reg [31:0] instr;
reg [31:0] base_addr;

wire memRW_mat;
wire vector_done;

wire vector_mem_valid;
wire vector_mem_write;
wire [31:0] vector_mem_addr;
wire [31:0] vector_mem_wdata;

reg vector_mem_ready;
reg [31:0] vector_mem_rdata;

vector_datapath dut
(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .base_addr(base_addr),

    .memRW_mat(memRW_mat),

    .vector_done(vector_done),

    .vector_mem_valid(vector_mem_valid),
    .vector_mem_write(vector_mem_write),
    .vector_mem_addr(vector_mem_addr),
    .vector_mem_wdata(vector_mem_wdata),

    .vector_mem_ready(vector_mem_ready),
    .vector_mem_rdata(vector_mem_rdata)
);

always #5 clk = ~clk;

integer count;

initial
begin

    clk = 0;
    rst = 1;

    instr = 32'd0;
    base_addr = 32'd0;

    vector_mem_ready = 0;
    vector_mem_rdata = 0;

    count = 0;

    #20;
    rst = 0;

    //---------------------------------------
    // Issue Vector Load
    //---------------------------------------

    base_addr = 0;

    // opcode 0000111
    instr = 32'h000000;
    wait(vector_done);

    $display("Vector Load Finished");

    #100;

    $finish;

end

//---------------------------------------
// Simple Memory Model
//---------------------------------------

always @(posedge clk)
begin

    vector_mem_ready <= 0;

    if(vector_mem_valid)
    begin

        vector_mem_ready <= 1;

        vector_mem_rdata <= count;

        count <= count + 1;

    end

end

//---------------------------------------
// Monitor
//---------------------------------------

initial
begin

$monitor(
"T=%0t CTRL=%0d VLSU=%0d start=%b done=%b",
$time,
dut.controller_dut.state,
dut.vlsu_dut.state,
dut.vlsu_start,
vector_done
);

end

endmodule