GCC=/opt/riscv/bin/riscv32-unknown-elf-gcc 
OBJ = /opt/riscv/bin/riscv32-unknown-elf-objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS= -fabi-version=6  -I./barebones -I. -c -march=rv32izbs -mabi=ilp32 -g -ffreestanding -O0 -nostartfiles 
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

div.o:div.S
	$(GCC) $(CFLAGS) -o $@ $^

muldi3.o:muldi3.S
	$(GCC) $(CFLAGS) -o $@ $^


final.elf:crt0.o eset_led.o trap_ack.o nmi_vec.o dbg_vec.o main.o div.o muldi3.o ee_printf.o
#ee_printf.o div.o muldi3.o
	$(GCC) $(LDFLAGS) -o $@ $^

final:final.elf
	$(OBJ) -O binary final.elf final

code_demo.mem32: final
	../common/bin2hex -w32  final > code_demo.mem32

clean:
	rm -rf *.o *.elf final code_demo.mem32