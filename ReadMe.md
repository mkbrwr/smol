# Compile swift sources
export TOOLCHAINS='org.swift.59202408051a' \
make all

# Generate swift module .h file
// WIP
swiftc -frontend -typecheck \
      -target armv7em-none-none-eabi -Osize -wmo -enable-experimental-feature Embedded -no-allocations -parse-as-library -import-bridging-header Bridging-Header.h \
       hello.swift -module-name SwiftModule \
       -cxx-interoperability-mode=default \
       -emit-clang-header-path SwiftModule-Swift.h \
       -Xcc -ffreestanding -Xcc -mcpu=cortex-m4 -Xcc -mthumb -Xcc -mfpu=fpv4-sp-d16 -Xcc -mfloat-abi=hard \

# Install command
% stm32-programmer-cli -c port=SWD -d build/STM32SMOL.bin 0x08000000 -v -rst

# Here's what you should see on the screen
![IMG_4341](https://github.com/user-attachments/assets/65bcaab6-7a10-462e-a1d3-e63990f6ce91)
