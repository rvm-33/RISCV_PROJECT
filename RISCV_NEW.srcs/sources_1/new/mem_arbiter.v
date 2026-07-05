//FROZEN 

`timescale 1ns / 1ps

module mem_arbiter#
(
    parameter VLEN = 512
)
(

input clk,
input rst,

//====================================
// Scalar LSU
//====================================

input               scalar_valid,
input               scalar_write,
input      [31:0]   scalar_addr,
input      [31:0] scalar_wdata,

output reg          scalar_ready,
output reg [31:0] scalar_rdata,

//====================================
// Vector LSU
//====================================

input               vector_valid,
input               vector_write,
input      [31:0]   vector_addr,
input      [31:0] vector_wdata,

output reg          vector_ready,
output reg [31:0] vector_rdata

);

//==================================================
// Memory Interface
//==================================================

reg mem_valid;
reg mem_write;

reg [31:0] mem_addr;
reg [31:0] mem_wdata;

wire mem_ready;
wire [31:0] mem_rdata;


//==================================================
// Data Memory
//==================================================

datMemory #(
    .VLEN(VLEN)
)
DMEM
(
    .clk(clk),
    .rst(rst),

    .mem_valid(mem_valid),
    .mem_write(mem_write),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),

    .mem_ready(mem_ready),
    .mem_rdata(mem_rdata)
);


//==================================================
// Arbitration
//==================================================

always @(*)
begin

    //-------------------------
    // Defaults
    //-------------------------

    mem_valid  = 0;
    mem_write  = 0;
    mem_addr   = 0;
    mem_wdata  = 0;

    scalar_ready = 0;
    vector_ready = 0;

    scalar_rdata = 0;
    vector_rdata = 0;

    //-------------------------
    // Scalar gets priority
    //-------------------------

    if(scalar_valid)
    begin

        mem_valid = 1;
        mem_write = scalar_write;

        mem_addr  = scalar_addr;
        mem_wdata = scalar_wdata;

        scalar_ready = mem_ready;
        scalar_rdata = mem_rdata;

    end

    //-------------------------
    // Vector access
    //-------------------------

    else if(vector_valid)
    begin

        mem_valid = 1;
        mem_write = vector_write;

        mem_addr  = vector_addr;
        mem_wdata = vector_wdata;

        vector_ready = mem_ready;
        vector_rdata = mem_rdata;

    end

end

endmodule