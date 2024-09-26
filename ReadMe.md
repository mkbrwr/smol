# Compile swift sources
export TOOLCHAINS='org.swift.59202408051a'
make

# Install command
stm32-programmer-cli -c port=SWD -d build/STM32SMOL.bin 0x08000000 -v -rst

# RTT
pyocd rtt --address 0x200009dc

It's an address from .map file for .bss._SEGGER_RTT
And can change when code is changed.
