LD=/c/riscv/bin/riscv-none-elf-gcc 
GCC=/c/riscv/bin/riscv-none-elf-gcc
OBJ = /c/riscv/bin/riscv-none-elf-objcopy
AR = /c/riscv/bin/riscv-none-elf-ar
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS= -I./barebones -I. -c  -march=rv32i_zbs_zicsr -mabi=ilp32 -O0  -finline-functions -falign-functions=16 -falign-jumps=4 -falign-loops=4 -finline-limit=1000 -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
CCFLAGS= -I./barebones -I. -c  -march=rv32ic_zbs_zicsr -mabi=ilp32 -O0  -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
ARFLAGS = rcs 
all:libcordic.a

cordic.o:cordic.c
	$(GCC) $(CFLAGS) -o $@ $^

libcordic.a:cordic.o
	$(AR) $(ARFLAGS)  -o $@ $^

clean:
	rm -rf *.o *.a