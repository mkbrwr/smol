# Compile swift sources
export TOOLCHAINS='org.swift.59202408051a'

/usr/bin/swiftc -target armv7em-none-none-eabi -Osize -wmo -enable-experimental-feature Embedded \
        -Xcc -D__APPLE__ -Xcc -D__MACH__ -Xcc -ffreestanding -Xcc -mcpu=cortex-m4 -Xcc -mthumb -Xcc -mfpu=fpv4-sp-d16 -Xcc -mfloat-abi=hard \
        -c hello.swift -o build/hello.o

# Generate swift module .h file

swiftc -frontend -typecheck \
      -target armv7em-none-none-eabi -Osize -wmo -enable-experimental-feature Embedded \
       hello.swift -module-name SwiftModule \
       -cxx-interoperability-mode=default \
       -emit-clang-header-path SwiftModule-Swift.h \
       -Xcc -D__APPLE__ -Xcc -D__MACH__ -Xcc -ffreestanding -Xcc -mcpu=cortex-m4 -Xcc -mthumb -Xcc -mfpu=fpv4-sp-d16 -Xcc -mfloat-abi=hard \

# Install command
% stm32-programmer-cli -c port=SWD -d build/STM32SMOL.bin 0x08000000 -v -rst
