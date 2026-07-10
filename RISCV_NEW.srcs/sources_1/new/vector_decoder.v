//FROZEN

`timescale 1ns / 1ps

module vector_decoder(

    input  [31:0] instr,
    // Instruction Valid
    output reg        vec_valid,

    // Operation Type
    output reg [3:0]  vec_op,

    // Register Operands
    output reg [4:0]  vd,
    output reg [4:0]  vs1,
    output reg [4:0]  vs2,
    output reg [4:0]  vs3,

    // Load/Store Information
    output reg [1:0]  addr_mode,
    output reg [2:0]  width,
    output reg        vm,
    output reg [2:0]  nf,

    // ALU Information
    output reg [5:0]  alu_op
);

//--------------------------------------------------
// Vector Operation Encoding
//--------------------------------------------------
localparam VEC_NONE   = 4'd0;
localparam VEC_LOAD   = 4'd1;
localparam VEC_STORE  = 4'd2;
localparam VEC_ALU    = 4'd3;
localparam VEC_CFG    = 4'd4;
localparam VEC_CUSTOM = 4'd5;

//--------------------------------------------------
// RVV Opcodes
//--------------------------------------------------
localparam OPCODE_VLOAD   = 7'b0000111;
localparam OPCODE_VSTORE  = 7'b0100111;
localparam OPCODE_VALU    = 7'b1010111;
localparam OPCODE_CUSTOM    = 7'b000000;


//--------------------------------------------------
// Combinational Decoder
//--------------------------------------------------
always @(*) begin

    //--------------------------------------------------
    // Defaults
    //--------------------------------------------------
    vec_valid = 1'b0;
    vec_op    = VEC_NONE;

    vd        = 5'd0;
    vs1       = 5'd0;
    vs2       = 5'd0;
    vs3       = 5'd0;

    addr_mode = 2'b00;
    width     = 3'b000;
    vm        = 1'b0;
    nf        = 3'b000;

    alu_op    = 6'b000000;

    //--------------------------------------------------
    // Decode Opcode
    //--------------------------------------------------
    case(instr[6:0])

    //--------------------------------------------------
    // Vector Load
    //--------------------------------------------------
    OPCODE_VLOAD: begin
        vec_valid = 1'b1;
        vec_op    = VEC_LOAD;
        vd        = instr[11:7];
        width     = instr[14:12];
        vs1       = instr[19:15];
        vm        = instr[25];
        addr_mode = instr[27:26];
        nf        = instr[31:29];

        if(addr_mode != 2'b00)
            vs2 = instr[24:20];
    end

    //--------------------------------------------------
    // Vector Store
    //--------------------------------------------------
    OPCODE_VSTORE: begin
        vec_valid = 1'b1;
        vec_op    = VEC_STORE;
        vs3       = instr[11:7];
        width     = instr[14:12];
        vs1       = instr[19:15];
        vm        = instr[25];
        addr_mode = instr[27:26];
        nf        = instr[31:29];
        if(addr_mode != 2'b00)
            vs2 = instr[24:20];
    end

    //--------------------------------------------------
    // Vector Arithmetic / Configuration
    //--------------------------------------------------
    OPCODE_VALU: begin
        vec_valid = 1'b1;
        // funct6 determines arithmetic/config/custom
        case(instr[31:26])
            // vsetvl / vsetvli / vsetivli
            6'b100000: begin
                vec_op = VEC_CFG;
            end
            default: begin
                vec_op = VEC_ALU;
                vd     = instr[11:7];
                vs1    = instr[19:15];
                vs2    = instr[24:20];
                vm     = instr[25];
                alu_op = instr[31:26];
            end
        endcase

    end

    //--------------------------------------------------
    // Custom Vector/Accelerator Instruction
    //--------------------------------------------------
    OPCODE_CUSTOM: begin
        vec_valid = 1'b1;
        vec_op    = VEC_CUSTOM;
        vd        = instr[11:7];
        vs1       = instr[19:15];
        vs2       = instr[24:20];
        vs3       = instr[31:27];
    end

    //--------------------------------------------------
    // Default
    //--------------------------------------------------
    default: begin
        vec_valid = 1'b0;
        vec_op    = VEC_NONE;
    end

    endcase

end

endmodule