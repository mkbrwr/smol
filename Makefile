TARGET = STM32SMOL

######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
# OPT = -Og

#######################################
# paths
#######################################
# Build path
BUILD_DIR = build
GCC_PATH = /Applications/ArmGNUToolchain/13.2.Rel1/arm-none-eabi/bin

######################################
# source
######################################
# C sources
C_SOURCES =  \
Support.c \
Core/Src/fmc.c \
Core/Src/spi.c \
Core/Src/gpio.c \
Core/Src/SEGGER_RTT_printf.c \
Core/Src/SEGGER_RTT.c \
Core/Src/ltdc.c \
Core/Src/syscalls.c \
Core/Src/i2c.c \
Core/Src/main.c \
Core/Src/usart.c \
Core/Src/sysmem.c \
Core/Src/system_stm32f4xx.c \
Core/Src/stm32f4xx_hal_msp.c \
Core/Src/dma2d.c \
Core/Src/stm32f4xx_it.c \
Drivers/BSP/Components/ili9341/ili9341.c \
Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery_ts.c \
Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery.c \
Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery_io.c \
Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery_lcd.c \
Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery_gyroscope.c \
Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery_sdram.c \
Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery_eeprom.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_spi.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_ltdc_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_fmc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_ltdc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma2d.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_sdram.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dsi.c \
Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c \
Game/Src/screen.c \
Game/Src/PixelData.c \

C_INCLUDES =  \
-Ibuild \
-ICore/Inc/ \
-IDrivers/STM32F4xx_HAL_Driver/Inc/ \
-IDrivers/ssd1306/ \
-IDrivers/CMSIS/Device/ST/STM32F4xx/Include/ \
-IDrivers/CMSIS/Include/ \
-IDrivers/BSP/STM32F429I-Discovery/ \
-IDrivers/BSP/Components/Common/ \
-IDrivers/BSP/Components/ili9341/ \
-IDrivers/BSP/Components/i3g4250d/ \
-IDrivers/BSP/Components/l3gd20/ \
-IDrivers/BSP/Components/stmpe811/ \
-IGame/Inc/ \


AS_SOURCES =  \
startup_stm32f429xx.s \

SWIFT_SOURCES =  \
Game/engine.swift \

#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4

# fpu
FPU = -mfpu=fpv4-sp-d16

# float-abi
FLOAT-ABI = -mfloat-abi=soft

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS += $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections -fno-stack-protector

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = STM32F429ZITx_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys
LIBDIR =
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(AS_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(AS_SOURCES)))

OBJECTS += build/engine.o

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.s=.lst)) $< -o $@

$(BUILD_DIR)/engine.o: Game/engine.swift Makefile | $(BUILD_DIR)
	swiftc -Xfrontend -disable-stack-protector -target armv7em-none-none-eabi -Osize -wmo -enable-experimental-feature Embedded -parse-as-library \
	-import-bridging-header Game/Bridging-Header.h \
	-Xcc -fno-stack-protector -Xcc -ffreestanding -Xcc -fdata-sections -Xcc -ffunction-sections -Xcc -mcpu=cortex-m4 -Xcc -mthumb -Xcc -mfpu=fpv4-sp-d16 -Xcc -mfloat-abi=soft \
    -c Game/engine.swift -o build/engine.o

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir $@

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***

stflash: $(BUILD_DIR)/$(TARGET).bin
	stm32-programmer-cli -c port=SWD -d $< 0x08000000 -v -rst
