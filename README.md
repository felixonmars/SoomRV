# SoomRV
## Description
SoomRV is a simple superscalar Out-of-Order RISC-V microprocessor. It can execute up to 4 instructions per cycle completely out of order, and also supports speculative execution and precise exceptions.

## Basic Architecture
<img src="https://user-images.githubusercontent.com/39701487/218574949-e18bcb51-5050-4f99-82a6-c8ea58c11a93.png" width="600" />

## Sample `strcmp` Execution (visualized using [Konata](https://github.com/shioyadan/Konata))
![Sample](https://user-images.githubusercontent.com/39701487/229142050-121ed8de-ae9b-4b49-b332-f6c7b5281daf.png)

## Features
- RV32IMACZicsrZifenceiZbaZbbZicbomZfinx Instruction Set
- 4-wide superscalar OoO Execution (tag-indexed register file, load after issue)
- Fully Out-of-Order Load/Store
- TAGE Branch Predictor
- Supports Instruction and Data Cache
- Implements RISC-V Supervisor Spec (M, S and U Mode, Virtual Memory)
- Currently scores 10.256 DMIPS/MHz at 2.721 IPC (`-march=rv32imac_zicsr_zba_zbb -O3 -finline-limit=128`, using `strcmp` implemented in `test_programs/entry.s`)

## Simulating
1. Install the [RV32 Linux Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) as well as Verilator (at least version 5.0).
2. Run `make setup` to build submodules.
3. Run `make` to build a binary with Verilator (alternatively, `make trace` will also generate VCD traces)
4. Run `./obj_dir/VTop <assembly file>` to execute the code in `<assembly file>`.  
For example, run `./obj_dir/VTop test_programs/dhry_1.s 2>/dev/null` to run Dhrystone (`stderr` contains Spike debug output).

## License
SoomRV is released under the MIT License. Use of this source code is governed by a MIT-style license that can be found in the `LICENSE` file.

### External Source Code
* `riscv-isa-sim` (aka `Spike`): released under the 3-Clause BSD License, used in conjunction with the simulator.
* `hardfloat`: released under the 3-Clause BSD License.

