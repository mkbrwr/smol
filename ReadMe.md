# Description
Drivers from STM example project, which are written in C, and Swift for application code.

# Result
![IMG_4343](https://github.com/user-attachments/assets/eab49c33-80f5-428e-be07-85be8f667c85)

# Build
export TOOLCHAINS='org.swift.61202409251a'
make

# Install command
stm32-programmer-cli -c port=SWD -d build/STM32SMOL.bin 0x08000000 -v -rst

# RTT
pyocd rtt --address 0x200009dc

0x200009dc is an address from .map file for .bss._SEGGER_RTT
And can change when code is changed.
