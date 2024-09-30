# Description
Drivers from STM example project, which are written in C, and Swift for application code.

# Result
https://github.com/user-attachments/assets/a562994b-f260-4b2c-b294-3c59a71c14f7

# Build
export TOOLCHAINS='org.swift.61202409251a'
make

# Install command
stm32-programmer-cli -c port=SWD -d build/STM32SMOL.bin 0x08000000 -v -rst

# RTT
pyocd rtt --address 0x200009dc

0x200009dc is an address from .map file for .bss._SEGGER_RTT
And can change when code is changed.
