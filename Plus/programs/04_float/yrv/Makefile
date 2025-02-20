LD=/c/riscv/bin/riscv-none-elf-gcc 
GCC=/c/riscv/bin/riscv-none-elf-gcc
OBJ = /c/riscv/bin/riscv-none-elf-objcopy
B2H = ../common/bin2hex
AR = /c/riscv/bin/riscv-none-elf-ar

export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS= -I./barebones -I. -c -march=rv32izbs -mabi=ilp32 -O0 -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
CCFLAGS= -I./barebones -I. -c -march=rv32iczbs -mabi=ilp32 -O0  -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000

LDFLAGS=  -nostdlib -Tyrv.ld  -nostartfiles -nostdlib
ARFLAGS = rcs 


all:libyrv.a

ee_printf.o:ee_printf.c
	$(GCC) $(CFLAGS) -o $@ $^

atoi.o:atoi.c
	$(GCC) $(CFLAGS) -o $@ $^

memset.o:memset.c
	$(GCC) $(CFLAGS) -o $@ $^

libyrv.a:ee_printf.o atoi.o memset.o
	$(AR) $(ARFLAGS)  -o $@ $^

clean:
	rm -rf *.o *.elf final code_demo.mem32