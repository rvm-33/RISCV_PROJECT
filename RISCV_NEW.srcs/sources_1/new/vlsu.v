`timescale 1ns / 1ps
//FROZEN
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2026 21:37:44
// Design Name: 
// Module Name: vlsu
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


module vlsu #(parameter VLEN=512)
(
    input clk,
    input rst,
    //==============================
    // Command Interface
    //==============================
    input         cmd_valid,
    output        cmd_ready,
    
    input         load,
    input         store,
    input [31:0]  base_addr,
    input [31:0]  vl,
    input [2:0]   sew,
    input [1:0]   addr_mode,
    input [31:0]  stride,
    input         vm,
    input [4:0]   vd,
    input [4:0]   vs3,
    
    //------------------------------------------------
    // VRF Write Port
    //------------------------------------------------
    output reg        vrf_w_en,
    output reg [4:0]  vrf_w_addr,
    output reg [511:0] vrf_w_data,
    //------------------------------------------------
    // VRF Read Port
    //------------------------------------------------
    output reg [4:0]  vrf_rd_addr01,
    output reg [4:0]  vrf_rd_addr02,
    input      [511:0] vrf_rdata01,
    input      [511:0] vrf_rdata02,
    //==============================
    // Memory Interface
    //==============================
    output  reg      mem_valid,
    input         mem_ready,
    output   reg     mem_write,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    input [31:0]  mem_rdata,
    //==============================
    // Status
    //==============================
    output busy,
    output done
);
reg [VLEN-1:0] vector_buffer;


integer i;

localparam IDLE        = 4'd0;
localparam LOAD_REQ    = 4'd1;
localparam WAIT_LOAD   = 4'd2;
localparam BUFFER_WORD = 4'd3;
localparam WRITE_VRF   = 4'd4;
localparam READ_VRF    = 4'd5;
localparam STORE_REQ   = 4'd6;
localparam WAIT_STORE  = 4'd7;
localparam DONE_STATE  = 4'd8;

reg [4:0] counter;
reg [2:0] state,next_state;
reg [31:0] addr;


    always @(posedge clk or posedge rst) begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    
     //----------------------------------------------------------
    // Sequential Datapath Registers
    //----------------------------------------------------------
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            addr            <= 32'd0;
            counter         <= 5'd0;
            vector_buffer <= {VLEN{1'b0}};
    
            mem_valid       <= 1'b0;
            mem_write       <= 1'b0;
            mem_addr        <= 32'd0;
            mem_wdata       <= 32'd0;
    
            vrf_w_en        <= 1'b0;
            vrf_w_addr      <= 5'd0;
            vrf_w_data      <= {VLEN{1'b0}};
    
            vrf_rd_addr01   <= 5'd0;
            vrf_rd_addr02   <= 5'd0;
        end
    
        else
        begin
    
            //----------------------------------
            // Default registered outputs
            //----------------------------------
            mem_valid <= 1'b0;
            mem_write <= 1'b0;
            vrf_w_en  <= 1'b0;
            case(state)
    
            //--------------------------------------------------
            // IDLE
            //--------------------------------------------------
            IDLE:
            begin
                if(cmd_valid)
                begin
                    addr <= base_addr;
                    counter  <= 5'd0;
                end
            end
    
            //--------------------------------------------------
            // LOAD REQUEST
            //--------------------------------------------------
            LOAD_REQ:
            begin
                mem_valid <= 1'b1;
                mem_write <= 1'b0;
                mem_addr  <= addr;
            end
    
            //--------------------------------------------------
            // WAIT LOAD
            //--------------------------------------------------
            WAIT_LOAD:
            begin
                // wait for mem_ready
            end
    
            //--------------------------------------------------
            // BUFFER ONE WORD
            //--------------------------------------------------
            BUFFER_WORD:
            begin
                vector_buffer[counter*32 +: 32] <= mem_rdata;
    
                addr <= addr + 32'd4;
                counter    <= counter + 5'd1;
            end
    
            //--------------------------------------------------
            // WRITE VECTOR TO VRF
            //--------------------------------------------------
            WRITE_VRF:
            begin
                vrf_w_en   <= 1'b1;
                vrf_w_addr <= vd;
                vrf_w_data <= vector_buffer;
            end
    
            //--------------------------------------------------
            // READ VECTOR FROM VRF
            //--------------------------------------------------
            READ_VRF:
            begin
                vrf_rd_addr01 <= vs3;
                vector_buffer <= vrf_rdata01;
                counter <= 5'd0;
            end
    
            //--------------------------------------------------
            // STORE REQUEST
            //--------------------------------------------------
            STORE_REQ:
            begin
                mem_valid <= 1'b1;
                mem_write <= 1'b1;
    
                mem_addr  <= addr;
                mem_wdata <= vector_buffer[counter*32 +: 32];
            end
    
            //--------------------------------------------------
            // WAIT STORE
            //--------------------------------------------------
            WAIT_STORE:
            begin
                if(mem_ready)
                begin
                    addr <= addr + 32'd4;
                    counter    <= counter + 5'd1;
                end
            end
    
            //--------------------------------------------------
            // DONE
            //--------------------------------------------------
            DONE_STATE:
            begin
                // Nothing
            end
    
            default:
            begin
            end
    
            endcase
    
        end
    end
    
    //----------------------------------------------------------
    // Next State Logic
    //----------------------------------------------------------
    always @(*)
    begin
        next_state = state;
        case(state)
        //--------------------------------------------------
        // IDLE
        //--------------------------------------------------
        IDLE:
        begin
            if(cmd_valid)
            begin
                if(load)
                    next_state = LOAD_REQ;
                else if(store)
                    next_state = READ_VRF;
            end
        end
    
        //--------------------------------------------------
        // LOAD REQUEST
        //--------------------------------------------------
        LOAD_REQ:
        begin
            next_state = WAIT_LOAD;
        end
    
        //--------------------------------------------------
        // WAIT FOR MEMORY (LOAD)
        //--------------------------------------------------
        WAIT_LOAD:
        begin
            if(mem_ready)
                next_state = BUFFER_WORD;
        end
    
        //--------------------------------------------------
        // BUFFER ONE WORD
        //--------------------------------------------------
        BUFFER_WORD:
        begin
            if(counter == (vl-1))
                next_state = WRITE_VRF;
            else
                next_state = LOAD_REQ;
        end
    
        //--------------------------------------------------
        // WRITE COMPLETE VECTOR TO VRF
        //--------------------------------------------------
        WRITE_VRF:
        begin
            next_state = DONE_STATE;
        end
    
        //--------------------------------------------------
        // READ COMPLETE VECTOR FROM VRF
        //--------------------------------------------------
        READ_VRF:
        begin
            next_state = STORE_REQ;
        end
    
        //--------------------------------------------------
        // STORE REQUEST
        //--------------------------------------------------
        STORE_REQ:
        begin
            next_state = WAIT_STORE;
        end
    
        //--------------------------------------------------
        // WAIT FOR MEMORY (STORE)
        //--------------------------------------------------
        WAIT_STORE:
        begin
            if(mem_ready)
            begin
                if(counter == (vl-1))
                    next_state = DONE_STATE;
                else
                    next_state = STORE_REQ;
            end
        end
        DONE_STATE:
        begin
            next_state = IDLE;
        end
    
        default:
        begin
            next_state = IDLE;
        end
        endcase
    end
    
endmodule
