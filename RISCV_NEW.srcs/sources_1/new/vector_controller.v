//FROZEN
`timescale 1ns / 1ps

module vector_controller(

    input clk,
    input rst,
    output reg mux_sel,
    //==============================
    // From Vector Decoder
    //==============================
    input        vec_valid,
    input [3:0]  vec_op,

    //==============================
    // Done Signals
    //==============================
    input vlsu_done,
    input valu_done,
    input accel_done,
    input cfg_done,

    //==============================
    // Start Signals
    //==============================
    output reg vlsu_start,
    output reg valu_start,
    output reg accel_start,
    output reg cfg_start,

    //==============================
    // Scalar Core Interface
    //==============================

    //==============================
    // Status
    //==============================
    output reg vec_done

);

//--------------------------------------------------
// Operation Encoding
//--------------------------------------------------

localparam OP_NONE   = 4'd0;
localparam OP_LOAD   = 4'd1;
localparam OP_STORE  = 4'd2;
localparam OP_VALU    = 4'd3;
localparam OP_CFG    = 4'd4;
localparam OP_ACCEL = 4'd5;
//--------------------------------------------------
// FSM States
//--------------------------------------------------

localparam IDLE        = 3'd0;
localparam WAIT_VLSU   = 3'd1;
localparam WAIT_VALU   = 3'd2;
localparam WAIT_ACCEL  = 3'd3;
localparam WAIT_CFG    = 3'd4;

reg [2:0] state;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        state <= IDLE;
        mux_sel <= 1'b0;

        vlsu_start  <= 1'b0;
        valu_start  <= 1'b0;
        accel_start <= 1'b0;
        cfg_start   <= 1'b0;
        vec_done <= 1'b0;

    end

    else
    begin

        //-----------------------------
        // Default pulse outputs
        //-----------------------------
        mux_sel <= mux_sel;
        vlsu_start  <= 1'b0;
        valu_start  <= 1'b0;
        accel_start <= 1'b0;
        cfg_start   <= 1'b0;
        vec_done    <= 1'b0;

        case(state)

        //---------------------------------------
        IDLE:
        begin


            if(vec_valid)
            begin

                case(vec_op)

                    OP_LOAD,
                    OP_STORE:
                    begin
                         mux_sel<=1'b0;
                        vlsu_start <= 1'b1;
                        state <= WAIT_VLSU;
                    end

                    OP_VALU:
                    begin
                        valu_start <= 1'b1;
                        state <= WAIT_VALU;
                    end

                    OP_ACCEL:
                    begin
                                    mux_sel<=1'b1;
                        accel_start <= 1'b1;
                        state <= WAIT_ACCEL;
                    end

                    OP_CFG:
                    begin
                        cfg_start <= 1'b1;
                        state <= WAIT_CFG;
                    end

                    default:
                    begin
                        state <= IDLE;
                    end

                endcase

            end

        end

        //---------------------------------------
        WAIT_VLSU:
        begin

            if(vlsu_done)
            begin
                vec_done <= 1'b1;
                state <= IDLE;
            end

        end

        //---------------------------------------
        WAIT_VALU:
        begin

            if(valu_done)
            begin
                vec_done <= 1'b1;
                state <= IDLE;
            end

        end

        //---------------------------------------
        WAIT_ACCEL:
        begin

            if(accel_done)
            begin
                vec_done <= 1'b1;
                state <= IDLE;
            end

        end

        //---------------------------------------
        WAIT_CFG:
        begin

            if(cfg_done)
            begin
                vec_done <= 1'b1;
                state <= IDLE;
            end

        end
        OP_NONE:
            begin
                state <= IDLE;
            end
        default:
        begin
            state <= IDLE;
        end

        endcase

    end

end

endmodule