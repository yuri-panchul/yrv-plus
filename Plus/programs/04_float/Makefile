LD=/c/riscv/bin/riscv-none-elf-gcc 
GCC=/c/riscv/bin/riscv-none-elf-gcc
OBJ = /c/riscv/bin/riscv-none-elf-objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS= -I. -c -march=rv32izbs -mabi=ilp32 -O0 -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
CCFLAGS= -I. -c -march=rv32iczbs -mabi=ilp32 -O0  -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000

LDFLAGS=  -nostdlib -Tyrv.ld  -nostartfiles -nostdlib


LDFLAGS=-nostdlib -Tyrv.ld

all:code_demo.mem32
trap_ack.o:trap_ack.s
	$(GCC) $(CFLAGS) -o $@ $^

eset_led.o:eset_led.s
	$(GCC) $(CFLAGS) -o $@ $^

nmi_vec.o:nmi_vec.s
	$(GCC) $(CFLAGS) -o $@ $^

dbg_vec.o:dbg_vec.s
	$(GCC) $(CFLAGS) -o $@ $^

crt0.o:crt0.s
	$(GCC) $(CFLAGS) -o $@ $^

main.o:main.c
	$(GCC) $(CFLAGS) -o $@ $^


final.elf:crt0.o eset_led.o trap_ack.o nmi_vec.o dbg_vec.o main.o 
	$(LD) $(LDFLAGS)  -o $@ $^  cordic/libcordic.a float/libfloat.a yrv/libyrv.a math/libmath.a 

final:final.elf
	$(OBJ) -O binary final.elf final

code_demo.mem32: final
	../common/bin2hex -w32  final > code_demo.mem32

clean:
	rm -rf *.o *.elf final code_demo.mem32