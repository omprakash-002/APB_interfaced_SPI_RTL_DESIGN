# APB-Interfaced SPI Master Controller RTL Design

A Verilog RTL implementation of an SPI master controller accessed through an APB-style programming interface. The top-level design connects APB register/control logic with SPI clock generation, slave selection, and serial data transmission/reception.

## Project Overview

The integrated `top` module connects these blocks:

| Directory | RTL module | Responsibility |
|---|---|---|
| `Apb_interface/` | `apb_interface` | APB transaction FSM, SPI configuration/status/data registers, and control-signal generation |
| `Baudrategenerator/` | `Baudrategenerator` | SPI clock generation, baud-rate divisor calculation, and MOSI/MISO timing pulses |
| `slave_select/` | `slave_select` | Slave-select control and transfer/receive timing indication |
| `shift_register/` | `shift_register` | Parallel-to-serial MOSI transmission and serial-to-parallel MISO reception |
| `Top_SPI/` | `top` | Integration of the APB interface and SPI datapath/control blocks |

## Top-Level Interface

| Signal | Direction | Description |
|---|---|---|
| `PCLK` | Input | APB/system clock |
| `PRESET_n` | Input | Active-low reset |
| `PADDR[2:0]` | Input | Register address |
| `PWRITE` | Input | APB write control |
| `PSEL` | Input | APB peripheral select |
| `PENABLE` | Input | APB access-phase control |
| `PWDATA[7:0]` | Input | APB write data |
| `PRDATA[7:0]` | Output | APB read data |
| `PREADY` | Output | APB transfer-ready indication |
| `PSLVERR` | Output | APB error indication |
| `MOSI` | Output | SPI master-out/slave-in data |
| `MISO` | Input | SPI master-in/slave-out data |
| `SCLK` | Output | SPI serial clock |
| `SS` | Output | Active-low slave-select |
| `spi_interrupt_request` | Output | SPI interrupt request |

## SPI Configuration

The APB interface exposes configuration signals used by the SPI logic:

- `spi_mode` and `spiswai`
- `sppr` and `spr` baud-rate prescaler fields
- `cpol` and `cpha` clock-polarity and clock-phase controls
- `lsbfe` bit-order control
- `mstr` master-mode control

The baud-rate generator calculates the divisor as:

```verilog
baudratedivisor = (sppr + 1) * (2 ** (spr + 1));
```

The shift-register logic uses `lsbfe`, `cpol`, and `cpha`, together with timing pulses from the baud-rate generator, to control serial data movement.

## Repository Structure

The original project folder structure is retained:

```text
APB_interface_SPI_design/
├── Apb_interface/
│   ├── apb_interface.v
│   ├── apb_interface_tb.v
│   └── simulation and synthesis screenshots
├── Baudrategenerator/
│   ├── Baudrategenerator.v
│   ├── Baudrategenerator_tb.v
│   └── simulation and synthesis screenshots
├── shift_register/
│   ├── shift_register.v
│   ├── Baudrategenerator.v
│   ├── shift_register_tb.v
│   └── simulation and synthesis screenshots
├── slave_select/
│   ├── slave_select.v
│   ├── slave_select_tb.v
│   └── simulation and synthesis screenshots
└── Top_SPI/
    ├── top.v
    ├── top_tb.v
    └── simulation and synthesis screenshots
```

## Simulation

The archive includes testbenches for the APB interface, baud-rate generator, shift register, slave-select block, and integrated top-level design.

To simulate the integrated design:

1. Add the RTL dependencies and `Top_SPI/top_tb.v` to your simulator project.
2. Compile the RTL files.
3. Set `top_tb` as the simulation top.
4. Run the simulation and inspect the waveform and console output.

Example QuestaSim commands (adjust paths and source order for your local setup):

```tcl
vlib work
vlog Apb_interface/apb_interface.v
vlog Baudrategenerator/Baudrategenerator.v
vlog slave_select/slave_select.v
vlog shift_register/shift_register.v
vlog Top_SPI/top.v
vlog Top_SPI/top_tb.v
vsim work.top_tb
add wave *
run -all
```

For block-level simulation, compile the relevant RTL and its testbench. The shift-register testbench also instantiates `Baudrategenerator`, so include that module when compiling it.

## Synthesis

The archive includes synthesis screenshots for the supplied blocks and integrated top-level design. To reproduce synthesis, select the intended RTL module as the synthesis top and include its dependencies. Testbench files are for simulation and must not be selected as synthesis sources.

The ZIP contains source files and result images; it does not include a portable, tool-version-specific synthesis project or build script.

## Tools and Languages

- Verilog HDL
- Xilinx ISE / XST (synthesis flow represented in the supplied project)
- QuestaSim or another Verilog simulator

## Project Scope

This README describes the RTL, testbench files, and screenshots present in the supplied project archive. Verification coverage and supported operating conditions should be interpreted from the included testbenches and results. This documentation does not claim exhaustive protocol compliance or complete functional coverage.

## Author

**Omprakash M**

GitHub: [omprakash-002](https://github.com/omprakash-002)
