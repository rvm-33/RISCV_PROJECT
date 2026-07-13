//Frozen no changes


`timescale 1ns / 1ps

module datMemory #
(
    parameter VLEN  = 512,
    parameter DEPTH = 1024
)
(
    input clk,
    input rst,

    //-----------------------------
    // Memory Request
    //-----------------------------
    input               mem_valid,
    input               mem_write,
    input      [31:0]   mem_addr,
    input      [31:0] mem_wdata,

    //-----------------------------
    // Memory Response
    //-----------------------------
    output reg          mem_ready,
    output reg [31:0] mem_rdata
);

reg [31:0] memory [0:DEPTH-1];

integer i;

wire [31:0] word_addr;

assign word_addr = mem_addr >> 2;

always @(posedge clk)
begin


if(rst)
    begin
    
        mem_ready <= 0;
        mem_rdata <= 0;
    
        for(i=0;i<DEPTH;i=i+1)
            memory[i] <= 32'd0;
    
        //----------------------------------------
        // DCT Test Vector
        // [10,20,30,40,50,60,70,80]
        //----------------------------------------
    
        memory[0] <= 32'd10;
        memory[1] <= 32'd20;
        memory[2] <= 32'd30;
        memory[3] <= 32'd40;
        memory[4] <= 32'd50;
        memory[5] <= 32'd60;
        memory[6] <= 32'd70;
        memory[7] <= 32'd80;
    
    end

    else
    begin

        mem_ready <= 0;

        if(mem_valid)
        begin

            mem_ready <= 1;

            if(mem_write)
                memory[word_addr] <= mem_wdata;
            else
                mem_rdata <= memory[word_addr];

        end

    end

end

endmodule