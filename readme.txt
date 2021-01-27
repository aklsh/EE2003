EE2003: Computer Organisation
=============================

DISCLAIMER: These are only for reference and are to be used only for understanding/learning. These assignments should not be turned in as your own original work.

NEWSFLASH: This is now being continued at hephaestus[1]

Tools
-----
* iverilog[2]
* gtkwave[3]
* direnv[4] (optional, but highly recommended)
* rv32i toolchain[5]
* yosys[6]
* Xilinx Vivado 2020.1[7] (optional - useful for beginners who have difficulty with CLI tools)

The tools are not provided as part of this repository and are to be built from source for latest features, and for easy management of tools.

Setup
-----
This setup assumes that you like to keep your global .profile clean and would like to add project-specific ENV_VARS(tools) to a separate file(directory) in the project. For this, direnv[4] is recommended. The .envrc present here assumes that you install the required tools in tools/ directory here.

DroneCI requires you to keep DRONE_TOKEN and DRONE_SERVER as ENV_VARS. Please add your DRONE_TOKEN credential to .envrc as:

    export DRONE_TOKEN=<insert token>

Assignments
-----------
a0 - Primer to git, DroneCI etc.
a1 - Primer on Verilog HDL
a2 - Primer on RISC-V assembly
a3 - ALU
# a4 was not released in time and was released in the end as a8.
a5 - Load/Store Instructions
a6 - Branch/Jump Instructions
a7 - Interfacing a peripheral with the processor
a8 - Synthesis

References
----------
[1] - https://github.com/aklsh/hephaestus
[2] - https://github.com/steveicarus/iverilog, install in tools/
[3] - https://github.com/gtkwave/gtkwave/tree/master/gtkwave3-gtk3, install in tools/
[4] - https://direnv.net/
[5] - build from source (https://github.com/riscv/riscv-tools). install in tools/ directory
[6] - https://github.com/YosysHQ/yosys - recommended to use v0.9 (support for RAM32, which is necessary, is introduced only in v0.9). install in tools/ directory
[7] - install in tools/
