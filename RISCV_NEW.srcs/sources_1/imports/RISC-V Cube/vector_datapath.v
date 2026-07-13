/* =============================================================================
File        : vector_datapath.v
Project     : RISC-V Vector Vedic Core IP Design on FPGA/ASIC

Description :
Integration wrapper for the vector pipeline. It wires the decoder,
controller, config unit, VLSU, VRF, accelerator and memory arbiter into a
single vector datapath block that can be instantiated from the top level.
=============================================================================
*/

`timescale 1ns/10ps

module vector_datapath#(parameter BIT_WIDTH = 8)(
    input clk,
    input rst,
    input vector_valid,
    input [31:0] instr,
    input [31:0] base_addr,
    output wire memRW_mat,
    output wire vector_done,
    output wire vector_mem_valid,
    output wire vector_mem_write,
    output wire [31:0] vector_mem_addr,
    output wire [31:0] vector_mem_wdata,
    input wire vector_mem_ready,
    input wire [31:0] vector_mem_rdata  //not used anywhere
);

    wire vec_valid;
    wire [3:0] vec_op;
    wire [4:0] vd;
    wire [4:0] vs1;
    wire [4:0] vs2;
    wire [4:0] vs3;
    wire [1:0] addr_mode;
    wire [2:0] width;
    wire vm;
    wire [2:0] nf;
    wire [5:0] alu_op;

    wire issue_valid;
    wire vlsu_start;
    wire accel_start;
    wire cfg_start;
    wire vlsu_done;
    wire accel_done;
    wire cfg_done;
    wire vec_done;

    wire vlsu_mem_valid;
    wire vlsu_mem_write;
    wire [31:0] vlsu_mem_addr;
    wire [31:0] vlsu_mem_wdata;
    wire mux_sel;
    wire vrf_w_en;
    wire [4:0] vrf_w_addr;
    wire [511:0] vrf_w_data;
    wire [4:0] vrf_rd_addr01;
    wire [4:0] vrf_rd_addr02;
    wire [511:0] vrf_rdata01;
    wire [511:0] vrf_rdata02;
    wire [511:0] temp;
    wire [31:0] cfg_vl  = 32'd16;
    wire [2:0]  cfg_sew = 3'b010;    // e32
    wire         cfg_vm = 1'b1;
    wire [511:0] accel_out;
//    if(vector_valid)begin    
        assign cfg_done = 1'b1;
        assign cfg_start=1'b1;
        assign issue_valid =vec_valid && vector_valid;
        assign memRW_mat = vlsu_mem_write;
        assign vector_done = vec_done;
        assign vector_mem_valid = vlsu_mem_valid;
        assign vector_mem_write = vlsu_mem_write;
        assign vector_mem_addr = vlsu_mem_addr;
        assign vector_mem_wdata = vlsu_mem_wdata;

	(* DONT_TOUCH = "TRUE" *)

    vector_decoder decoder_dut(
        .instr(instr),
        .vec_valid(vec_valid),
        .vec_op(vec_op),
        .vd(vd),
        .vs1(vs1),
        .vs2(vs2),
        .vs3(vs3),
        .addr_mode(addr_mode),
        .width(width),
        .vm(vm),
        .nf(nf),
        .alu_op(alu_op)
    );
	(* DONT_TOUCH = "TRUE" *)

    vector_controller controller_dut(
        .clk(clk),
        .rst(rst),
        .mux_sel(mux_sel),
        .vec_valid(issue_valid),
        .vec_op(vec_op),
        .vlsu_done(vlsu_done),
        .valu_done(1'b0),
        .accel_done(accel_done),
        .cfg_done(cfg_done),
        .vlsu_start(vlsu_start),
        .valu_start(),//what is this
        .accel_start(accel_start),
        .cfg_start(cfg_start),
        .vec_done(vec_done)
    );

//    config_unit config_dut(
//        .clk(clk),
//        .rst(rst),
//        .start(cfg_start),
//        .done(cfg_done),
//        .vl(cfg_vl),
//        .sew(cfg_sew),
//        .vm(cfg_vm)
//    );
	(* DONT_TOUCH = "TRUE" *)

    vlsu #(.VLEN(512)) vlsu_dut(
        .clk(clk),
        .rst(rst),
        .cmd_valid(vlsu_start),
        .cmd_ready(),//what to put
        .load(vec_op == 4'd1),
        .store(vec_op == 4'd2),
        .base_addr(base_addr),
        .vl(cfg_vl),
        .sew(cfg_sew),
        .addr_mode(addr_mode),
        .stride({27'b0, vs2}),
        .vm(cfg_vm),
        .vd(vd),
        .vs3(vs3),
        .vrf_w_en(vrf_w_en),
        .vrf_w_addr(vrf_w_addr),
        .vrf_w_data(vrf_w_data),
        .vrf_rd_addr01(vrf_rd_addr01),
        .vrf_rd_addr02(vrf_rd_addr02),
        .vrf_rdata01(vrf_rdata01),
        .vrf_rdata02(vrf_rdata02),
        .mem_valid(vlsu_mem_valid),
        .mem_ready(vector_mem_ready),
        .mem_write(vlsu_mem_write),
        .mem_addr(vlsu_mem_addr),
        .mem_wdata(vlsu_mem_wdata),
        .mem_rdata(vector_mem_rdata),
        .busy(),//why free
        .done(vlsu_done)
    );
    (* DONT_TOUCH = "TRUE" *)

    MUX2x1_v mux_dut(
    .clk(clk),
    .inp1(vrf_w_data),
    .inp2(accel_out),
    .sel(mux_sel),
    .out(temp)
    );
(* DONT_TOUCH = "TRUE" *)

    vregFile #(.VLEN(512), .REG_COUNT(32)) vrf_dut(
        .clk(clk),
        .rst(rst),
        .w_en(vrf_w_en),
        .w_addr01(vrf_w_addr),
        .wdata_512(temp),
        .rd_addr01(vrf_rd_addr01),
        .rd_addr02(vrf_rd_addr02),
        .rdata_512_01(vrf_rdata01),
        .rdata_512_02(vrf_rdata02)
    );
(* DONT_TOUCH = "TRUE" *)

    accelerator accel_dut(
        .clk(clk),
        .rst(rst),
        .start(accel_start),
        .done(accel_done),
        .valid_in(1'b1),
        .ready_in(),//??
        .input_vector(vrf_rdata01),
        .valid_out(),//??
        .ready_out(1'b1),
        .output_vector(accel_out)
    );

endmodule
