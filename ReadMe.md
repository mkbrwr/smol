# Description
Drivers from STM example project, which are written in C, and Swift for application code.

# Result
https://github.com/user-attachments/assets/0ac91656-3581-465b-b653-f9f7dc9f7174

# Build
// Temporary note!
// Building requires building your own local toolchain with a fix for object deallocaiton
// if not, program will run for a couple of seconds and then run out of memory
export TOOLCHAINS='org.swift.61202409251a'
make

# Install command
stm32-programmer-cli -c port=SWD -d build/STM32SMOL.bin 0x08000000 -v -rst

# RTT
pyocd rtt --address 0x200009dc

0x200009dc is an address from .map file for .bss._SEGGER_RTT
And can change when code is changed.
