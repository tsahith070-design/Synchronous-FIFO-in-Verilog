# Synchronous FIFO in Verilog 🔁

A parameterized, synchronous FIFO (First-In-First-Out) buffer designed in Verilog, along with a basic testbench to verify its core functionality.

## 📁 Files
| File | Description |
|------|-------------|
| `fifo_design.v` | FIFO RTL design |
| `fifo_tb.sv` | Testbench |

## ⚙️ Parameters
| Parameter | Default | Description |
|-----------|---------|--------------|
| `DATA_WIDTH` | 8 | Width of each data word |
| `FIFO_DEPTH` | 16 | Number of storage locations |

## ✨ Features
- Synchronous read and write operations
- Asynchronous, active-high reset
- Full and empty flag generation
- Live occupancy counter (`count`)

## 🧪 Testbench Coverage
- Reset behavior
- Filling the FIFO to full, and blocking further writes
- Draining the FIFO to empty, checking correct read order
- Simultaneous read and write
- Asynchronous reset mid-operation

## ▶️ How to Run
Compile and simulate `fifo_design.v` and `fifo_tb.sv` together using any Verilog/SystemVerilog simulator — e.g. Vivado XSIM, Icarus Verilog, or ModelSim.

```bash
# Example with Icarus Verilog
iverilog -g2012 -o fifo_sim fifo_design.v fifo_tb.sv
vvp fifo_sim
```
