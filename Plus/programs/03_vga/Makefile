LD=/opt/riscv_native/bin/riscv32-unknown-elf-gcc 
GCC=/opt/riscv_native/bin/riscv32-unknown-elf-gcc
OBJ = /opt/riscv_native/bin/riscv32-unknown-elf-objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS= -I./barebones -I. -c -march=rv32izbs -mabi=ilp32 -O2  -finline-functions -falign-functions=16 -falign-jumps=4 -falign-loops=4 -finline-limit=1000 -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
CCFLAGS= -I./barebones -I. -c -march=rv32iczbs -mabi=ilp32 -O2  -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
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

ee_printf.o:ee_printf.c
	$(GCC) $(CFLAGS) -o $@ $^

atoi.o:atoi.c
	$(GCC) $(CFLAGS) -o $@ $^
memset.o:memset.c
	$(GCC) $(CFLAGS) -o $@ $^

div.o:div.S
	$(GCC) $(CFLAGS) -o $@ $^

muldi3.o:muldi3.S
	$(GCC) $(CCFLAGS) -o $@ $^



final.elf:crt0.o eset_led.o trap_ack.o nmi_vec.o dbg_vec.o main.o ee_printf.o atoi.o memset.o div.o muldi3.o
	$(LD) $(LDFLAGS)  -o $@ $^

final:final.elf
	$(OBJ) -O binary final.elf final

code_demo.mem32: final
	../common/bin2hex -w32  final > code_demo.mem32

clean:
	rm -rf *.o *.elf final code_demo.mem32