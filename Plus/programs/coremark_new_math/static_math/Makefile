LD=/opt/riscv_native/bin/riscv32-unknown-elf-gcc 
GCC=/opt/riscv_native/bin/riscv32-unknown-elf-gcc
OBJ = /opt/riscv_native/bin/riscv32-unknown-elf-objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS=  -I./barebones -I. -c -march=rv32i -mabi=ilp32 -g -ffreestanding -O0 -nostartfiles 
CIFLAGS=  -I./barebones -I. -c -march=rv32i -mabi=ilp32 -g -ffreestanding -O0 -nostartfiles 

LDFLAGS=-nostdlib -Tyrv.ld 

all:_mulsi3.o _divsi3.o _udivsi3.o _umodsi3.o _modsi3.o
	
_mulsi3.o:_mulsi3.s
	$(GCC) $(CFLAGS) -o $@ $^

_divsi3.o:_divsi3.s
	$(GCC) $(CFLAGS) -o $@ $^

_udivsi3.o:_udivsi3.s
	$(GCC) $(CFLAGS) -o $@ $^

_umodsi3.o:_umodsi3.s
	$(GCC) $(CFLAGS) -o $@ $^

_modsi3.o:_modsi3.s
	$(GCC) $(CFLAGS) -o $@ $^

clean:
	rm -rf *.o *.a