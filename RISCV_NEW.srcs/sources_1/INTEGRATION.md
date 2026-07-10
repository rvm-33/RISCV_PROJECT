# Integration Document

## Overview
This document captures the current module interfaces and the intended integration contract for the scalar/vector architecture.

The architecture should be treated as a real system with separate responsibilities:
- Scalar Core / Scalar Controller
- Vector Decoder
- Vector Controller
- Config Unit
- VLSU
- Accelerator
- VRF
- Memory Arbiter
- Data Memory
- Top-level integration

## Current Top-Level Instantiation
`imports/RISC-V Cube/top.v` currently instantiates:
- `ctrlLogic` (scalar controller)
- `datapath` (scalar core)
- `vector_datapath` (vector datapath / co-processor interface)

### Current top-level connections
- `ctrlLogic.inst` is connected from `datapath` instruction fetch
- `ctrlLogic` controls `datapath` scalar execution signals
- `ctrlLogic.begin_coprocessor` / `controlsig_coprocessor` are passed to `vector_datapath`
- `datapath.stall_vector` is driven by `vector_datapath`
- `datapath` and `vector_datapath` share the 512-bit memory interface signals

## Module Interface Map

### `top`
Inputs:
- `clk`, `clk_f`, `rst`
Outputs:
- scalar control signals, vector control/status signals, datapath debug outputs
Connected to:
- `ctrlLogic`, `datapath`, `vector_datapath`

### `ctrlLogic` (`imports/RISC-V Cube/ctrlLogic.v`)
Inputs:
- `clk`, `rst`
- `inst`
- `brEQ`, `brLT`, `brGE`
- `co_processor_done`
Outputs:
- `PCSel`, `immSel`, `regWEn`, `brUn`, `aSel`, `bSel`, `aluSel`, `memRW`, `wbSel`
- `begin_coprocessor`, `controlsig_coprocessor`
- `stall_program`
Connected to:
- `datapath` (scalar control)
- `vector_datapath` (co-processor handshake)
- `top` (status/debug)

### `datapath` (`imports/RISC-V Cube/datapath.v`)
Inputs:
- `clk`, `clk_f`, `rst`
- scalar control signals from `ctrlLogic`
- `sel_mat`, `j`, `stall_vector`, `memRW_mat`, `datMem_512_out`, `stall_program`
Outputs:
- `inst`, `brEQ`, `brLT`, `brGE`
- `MM_Addr_in`, `dest_addr_dcmem`
- `datMem_512_in`, `pcUpd_1`, `progCnt_1`, debug outputs
Connected to:
- `ctrlLogic` (scalar control)
- `insMemory` (instruction fetch)
- `regFile`, `alu`, `jump`, `immGen`, `datMemory` inside scalar datapath
- `vector_datapath` (vector memory/control interface)

### `vector_datapath` (`imports/RISC-V Cube/vector_datapath.v`)
Inputs:
- `clk`, `rst`
- `src_adrr_dmem`, `dest_addr_dmem`
- `datMem_512_in`
- `begin_var`, `controlsig_1`
Outputs:
- `stall_vector`
- `memRW_mat`
- `j`
- `sel_mat`
- `datMem_512_out`
Connected to:
- `top` (control/status)
- `datapath` (stall, memory interface)

### `vector_decoder` (`new/vector_decoder.v`)
Inputs:
- `instr` (32-bit instruction)
Outputs:
- `vec_valid`
- `vec_op`
- `vd`, `vs1`, `vs2`, `vs3`
- `addr_mode`, `width`, `vm`, `nf`
- `alu_op`
Connected to:
- intended to connect from `ctrlLogic` / scalar controller when `Opcode = Custom`
- intended to feed `vector_controller`

### `vector_controller` (`new/vector_controller.v`)
Inputs:
- `clk`, `rst`
- `vec_valid`, `vec_op`
- `vlsu_done`, `valu_done`, `accel_done`, `cfg_done`
Outputs:
- `vlsu_start`, `valu_start`, `accel_start`, `cfg_start`
- `stall_scalar`
- `vec_done`
Connected to:
- intended to receive decoded vector instruction info from `vector_decoder`
- intended to start `vlsu`, `accelerator`, `config unit`
- intended to stall scalar core while vector operation executes

### `vlsu` (`new/vlsu.v`)
Inputs:
- `clk`, `rst`
- `cmd_valid`, `load`, `store`
- `base_addr`, `vl`, `sew`, `addr_mode`, `stride`, `vm`
- `vd`, `vs3`
- `vrf_rdata01`, `vrf_rdata02`
- `mem_ready`, `mem_rdata`
Outputs:
- `cmd_ready`
- `vrf_w_en`, `vrf_w_addr`, `vrf_w_data`
- `vrf_rd_addr01`, `vrf_rd_addr02`
- `mem_valid`, `mem_write`, `mem_addr`, `mem_wdata`
- `busy`, `done`
Connected to:
- `vector_controller` / command interface
- `VRF` read/write ports
- `Memory Arbiter` for memory requests

### `mem_arbiter` (`new/mem_arbiter.v`)
Inputs:
- scalar request: `scalar_valid`, `scalar_write`, `scalar_addr`, `scalar_wdata`
- vector request: `vector_valid`, `vector_write`, `vector_addr`, `vector_wdata`
Outputs:
- scalar response: `scalar_ready`, `scalar_rdata`
- vector response: `vector_ready`, `vector_rdata`
Connected to:
- `datMemory` (shared data memory)
- intended to arbitrate between `Scalar LSU` and `Vector LSU`

### `datMemory` (`imports/RISC-V Cube/datMemory.v`)
Inputs:
- `clk`, `rst`
- `mem_valid`, `mem_write`, `mem_addr`, `mem_wdata`
Outputs:
- `mem_ready`, `mem_rdata`
Connected to:
- `mem_arbiter`

### `vregFile` / VRF (`imports/RISC-V Cube/vregfile.v`)
Inputs:
- `clk`, `rst`
- `w_en`, `w_addr01`, `wdata_512`
- `rd_addr01`, `rd_addr02`
Outputs:
- `rdata_512_01`, `rdata_512_02`
Connected to:
- `VLSU` (write port)
- `Accelerator` (read/write ports)
- should connect to `vector_controller` for operand addresses

### `accelerator` (`imports/RISC-V Cube/vec_mult.v`)
Inputs:
- `clk`, `rst`
- `start`
- `valid_in`, `input_vector`, `ready_out`
Outputs:
- `done`
- `ready_in`, `valid_out`, `output_vector`
Connected to:
- `vector_controller`
- `VRF`

## Missing / Not Yet Connected Modules

- `vector_decoder` is present but not instantiated in `top.v`.
- `vector_controller` is present but not instantiated in `top.v`.
- `vlsu` is present but not instantiated or connected in top-level design.
- `mem_arbiter` is present but not instantiated or connected.
- `vregFile` exists and should provide the `VRF` interface, but it is not currently instantiated at top-level.
- `accelerator` is defined, but no wrapper or instantiation exists in the top-level design.
- `Config Unit` does not currently exist as a separate module and should be added when the design is integrated.
- `Scalar LSU` is not a separate module in current RTL; scalar memory access is handled by `datapath` / `datMemory` directly.

## Proposed Integration Contract

### Scalar Controller -> Vector Decoder
- `ctrlLogic` should detect `Opcode == 7'b0001011` (Custom)
- When custom opcode is seen, `ctrlLogic` should hand the entire `instr` to `vector_decoder`
- `vector_decoder` outputs `vec_valid`, `vec_op`, operand registers, modes, and fields

### Vector Decoder -> Vector Controller
- `vector_decoder` outputs feed directly into `vector_controller`
- `vector_controller` only needs `vec_valid` / `vec_op` to choose start signals
- Additional fields should be packaged into selected slave modules (VLSU / accelerator / config unit)

### Vector Controller -> VLSU / Accelerator / Config Unit
- `vector_controller` should assert one of: `vlsu_start`, `accel_start`, or `cfg_start`
- `vector_controller` should hold `stall_scalar` until the selected unit asserts `done`

### Configuration
- Hardcode a simple config unit with outputs: `VL = 16`, `SEW = 32`, `VM = 1`
- No `vsetvli` support yet

### VLSU -> Memory / VRF
- `VLSU` should receive `base_addr`, `VL`, `SEW`, `VD`, `VS3`, `addr_mode`, `vm`
- `VLSU` makes a memory request through `mem_arbiter`
- `VLSU` writes loaded data to the `VRF`

### VRF
- Provide `2 read, 1 write` ports
- `VLSU` writes loaded vector data
- `Accelerator` reads operands and writes results back

### Memory Arbiter
- Choose between scalar and vector memory requests
- Only `datMemory` connects to memory
- The arbiter drives `datMemory.mem_valid`, `mem_write`, `mem_addr`, `mem_wdata`

## Integration Notes

- The current `vector_datapath` module already uses a shared 512-bit memory interface, but it is not aligned with the new vector controller / VLSU / VRF contract.
- `datapath` currently includes a `datMemory` separate from `mem_arbiter`; a clean integration should centralize data memory behind `mem_arbiter` and have scalar/vector requests go through it.
- The `ctrlLogic` custom instruction path already exists. It is the natural hook for `vector_decoder`.
- The current `vector_controller` FSM is a good contract for start/done/stall behavior.

## Recommended Next Step

1. Instantiate `vector_decoder` in `top.v` and connect `datapath.inst` to it when `ctrlLogic` detects custom opcode.
2. Instantiate `vector_controller` and connect its start/done interfaces to the selected backend modules.
3. Instantiate `vlsu`, `mem_arbiter`, `vregFile`, and `accelerator` in `top.v`.
4. Add a simple `config_unit` module or hardcode `VL=16, SEW=32, VM=1` in the top-level integration.
5. Keep internal module RTL unchanged until integration is verified.
