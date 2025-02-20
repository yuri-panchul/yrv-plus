LD=/c/riscv/bin/riscv-none-elf-gcc 
GCC=/c/riscv/bin/riscv-none-elf-gcc
OBJ = /c/riscv/bin/riscv-none-elf-objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS= -I./barebones -I. -c -march=rv32izbs -mabi=ilp32 -O0 -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
CCFLAGS= -I./barebones -I. -c -march=rv32iczbs -mabi=ilp32 -O0  -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000

LDFLAGS=  -nostdlib -Tyrv.ld  -nostartfiles -nostdlib
ARFLAGS = rcs 


all:libmath.a

div.o:div.S
	$(GCC) $(CFLAGS) -o $@ $^

muldi3.o:muldi3.S
	$(GCC) $(CCFLAGS) -o $@ $^


libmath.a:muldi3.o div.o
	$(AR) $(ARFLAGS)  -o $@ $^

clean:
	rm -rf *.o *.elf final code_demo.mem32