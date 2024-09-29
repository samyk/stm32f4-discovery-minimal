# update this path to your stm periph lib
STM_PERIPH=../STM32F4xx_DSP_StdPeriph_Lib_V1.9.0

# update this to match your target board
TARGET = STM32F446RE

BOARD=$(shell grep ${STM_PERIPH}/Libraries/CMSIS/Device/ST/STM32F4xx/Include/stm32f4xx.h -e ${TARGET} | perl -ne 'print $$1 if /\#define\s+(\w+)/')
# or set BOARD=STM32F446xx (or whatever based on stm32f4xx.h)
#BOARD = STM32F446xx
#BOARD = STM32F429_439xx

SRCS=*.c

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

CFLAGS = -g -O2 -Wall
CFLAGS += -T $(STM_PERIPH)/Project/STM32F4xx_StdPeriph_Templates/TrueSTUDIO/$(BOARD)/*_FLASH.ld
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += --specs=nosys.specs
CFLAGS += -DUSE_STDPERIPH_DRIVER
CFLAGS += -D$(BOARD) # -DSTM32F446RE # -DSTM32F429_439xx #Update this to match your board.
CFLAGS += -I.
CFLAGS += -I$(STM_PERIPH)/Libraries/CMSIS/Include
CFLAGS += -I$(STM_PERIPH)/Libraries/CMSIS/Device/ST/STM32F4xx/Include
CFLAGS += -I$(STM_PERIPH)/Libraries/STM32F4xx_StdPeriph_Driver/inc
CFLAGS += -I$(STM_PERIPH)/Project/STM32F4xx_StdPeriph_Templates

SRCS += $(STM_PERIPH)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_gpio.c
SRCS += $(STM_PERIPH)/Libraries/STM32F4xx_StdPeriph_Driver/src/stm32f4xx_rcc.c
SRCS += $(STM_PERIPH)/Project/STM32F4xx_StdPeriph_Templates/system_stm32f4xx.c
SRCS += $(STM_PERIPH)/Libraries/CMSIS/Device/ST/STM32F4xx/Source/Templates/TrueSTUDIO/startup_stm32f429_439xx.s

.PHONY: toggle

all: toggle

toggle: toggle.elf

toggle.elf: $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@ 
	$(OBJCOPY) -O binary toggle.elf toggle.bin

flash: toggle
	st-flash write toggle.bin 0x8000000

clean:
	rm -f toggle.elf toggle.bin
