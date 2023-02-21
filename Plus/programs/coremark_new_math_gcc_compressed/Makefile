GCC=/opt/riscv_emb/bin/riscv-none-elf-gcc
#GCC=/opt/xpack/bin/riscv-none-elf-gcc
OBJ = /opt/xpack/bin/riscv-none-elf-objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS= -I./barebones -I. -c -march=rv32izbs -mabi=ilp32 -Os  -finline-functions -falign-functions=16 -falign-jumps=4 -falign-loops=4 -finline-limit=1000 -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
CCFLAGS= -I./barebones -I. -c -march=rv32iczbs -mabi=ilp32 -O2  -ffreestanding -fno-zero-initialized-in-bss -DPERFORMANCE_RUN=1 -DITERATIONS=1000
LDFLAGS=  -nostdlib -Tyrv.ld  -nostartfiles -nostdlib
#-mcmodel=medany
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

div.o:div.S
	$(GCC) $(CFLAGS) -o $@ $^

muldi3.o:muldi3.S
	$(GCC) $(CCFLAGS) -o $@ $^


core_list_join.o:core_list_join.c
	$(GCC) $(CFLAGS) -o $@ $^

core_main.o:core_main.c
	$(GCC) $(CFLAGS) -DFLAGS_STR="" -DCOMPILER_FLAGS="\"\"" -o $@ $^

core_matrix.o:core_matrix.c
	$(GCC) $(CFLAGS) -o $@ $^

core_state.o:core_state.c
	$(GCC) $(CFLAGS) -o $@ $^

core_util.o:core_util.c
	$(GCC) $(CCFLAGS) -o $@ $^

memset.o:memset.c
	$(GCC) $(CCFLAGS) -o $@ $^

memcpy.o:memcpy.c
	$(GCC) $(CCFLAGS) -o $@ $^

bcopy.o:bcopy.c
	$(GCC) $(CCFLAGS) -o $@ $^

memmove.o:memmove.c
	$(GCC) $(CCFLAGS) -o $@ $^

strlen.o:strlen.c
	$(GCC) $(CCFLAGS) -o $@ $^

core_portme.o:barebones/core_portme.c
	$(GCC) $(CFLAGS) -o $@ $^

ee_printf.o:barebones/ee_printf.c
	$(GCC) $(CCFLAGS) -o $@ $^

cvt.o:barebones/cvt.c
	$(GCC) $(CFLAGS) -o $@ $^



main.o:main.c
	$(GCC) $(CCFLAGS) -o $@ $^

final.elf:crt0.o eset_led.o trap_ack.o nmi_vec.o dbg_vec.o core_list_join.o core_main.o core_matrix.o core_state.o core_util.o core_portme.o ee_printf.o memset.o memcpy.o bcopy.o memmove.o strlen.o div.o muldi3.o
	$(GCC) $(LDFLAGS) -o $@ $^ 

final:final.elf
	$(OBJ) -O binary final.elf final

code_demo.mem32: final
	../common/bin2hex -w32  final > code_demo.mem32

clean:
	rm -rf *.o *.elf final code_demo.mem32