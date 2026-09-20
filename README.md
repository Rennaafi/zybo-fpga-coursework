# FPGA Coursework — Zybo Z7-10

RTL exercises from a structured Verilog/FPGA training program, built and verified on a Digilent Zybo Z7-10 (Xilinx Zynq-7000) in Vivado. Each folder is a self-contained module: source files, testbenches where written, and board constraints where applicable. Vivado project/build artifacts (`.cache`, `.runs`, `.sim`, `.ip_user_files`, `.xpr`) are intentionally excluded — only the authored RTL is kept.

## Contents

| # | Topic | Highlights |
|---|-------|------------|
| [01](01-logic-gates) | Logic gates | AND/OR/XOR/NAND on switches → LEDs |
| [02](02-2to1-multiplexer) | 2-to-1 multiplexer | Structural mux built from gates, plus a challenge variant |
| [03](03-comparator-running-light) | Comparator & running light | 4-bit comparator, mux-driven running-light pattern |
| [04](04-alu) | ALU | Arithmetic/logic unit with testbench |
| [05](05-4bit-counter) | 4-bit counter | Synchronous counter with two testbenches |
| [06](06-microsecond-tick-generator) | Microsecond tick generator | Clock-to-microsecond tick divider |
| [07](07-clock-divider-and-tick) | Clock divider & tick | Configurable clock division with tick output |
| [08](08-debouncer-and-blinking-led) | Debouncer & blinking LED | Button debounce feeding an LED blink FSM |
| [09](09-fsm-sequential-design) | FSM & sequential design | Vending machine, Mealy automatic door, Moore traffic light, coffee-vending practice, digital lock keypad |
| [10](10-uart-communication) | UART communication | HC-SR04 ultrasonic range → UART report, and a minimal UART TX |
| [11](11-riscv-core-mini) | RISC-V core (mini) | Minimal single-cycle RISC-V core with ALU and bus arbiter |
| [12](12-riscv-soc) | RISC-V SoC | Fuller SoC integration: BRAM/DDR/UART/VGA/interrupt controllers around the core |
| [shared-constraints](shared-constraints) | Board constraints | Master Zybo Z7-10 `.xdc` pin mapping |

## Notes on curation

A few exercises existed as two attempts (a first pass and a cleaned-up revision). Only the more complete/polished version is kept here to avoid duplicate, half-finished copies:
- **Digital lock key** (chapter 9) keeps the standalone, better-commented revision over the earlier in-chapter draft.
- **Clock divider & tick** (chapter 7) keeps the primary attempt over the "practice copy" redo.
- A malformed duplicate (`basic gates.v`, invalid Verilog identifier with a space in the module name) was dropped in favor of the working `basic_gates.v`.

## Toolchain

Vivado 2024.x targeting `xc7z010clg400-1` (Zybo Z7-10). Each module was synthesized and tested on real hardware unless noted otherwise in its subfolder.
