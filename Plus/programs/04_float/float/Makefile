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
all:libfloat.a

fabs.o:fabs.c
	$(GCC) $(CFLAGS) -o $@ $^
fp-precision.o:fp-precision.c
	$(GCC) $(CFLAGS) -o $@ $^
fp-mul32.o:fp-mul32.c
	$(GCC) $(CFLAGS) -o $@ $^
floatsisf.o:floatsisf.S 	
	$(GCC) $(CFLAGS) -o $@ $^
addsf3.o:addsf3.S
	$(GCC) $(CFLAGS) -o $@ $^
muldi3.o:muldi3.S
	$(GCC) $(CCFLAGS) -o $@ $^
extendsfdf2.o:extendsfdf2.S
	$(GCC) $(CFLAGS) -o $@ $^
fixsfsi.o:fixsfsi.S
	$(GCC) $(CFLAGS) -o $@ $^
ltsf2.o:ltsf2.S
	$(GCC) $(CFLAGS) -o $@ $^
ltdf2.o:ltdf2.S
	$(GCC) $(CFLAGS) -o $@ $^
adddf3.o:adddf3.S
	$(GCC) $(CFLAGS) -o $@ $^
divdf3.o:divdf3.S
	$(GCC) $(CFLAGS) -o $@ $^
truncdfsf2.o:truncdfsf2.S
	$(GCC) $(CFLAGS) -o $@ $^
gesf2.o: gesf2.S
	$(GCC) $(CFLAGS) -o $@ $^
eqsf2.o:eqsf2.S
	$(GCC) $(CFLAGS) -o $@ $^
eqdf2.o:eqdf2.S
	$(GCC) $(CFLAGS) -o $@ $^
divsf3.o:divsf3.S
	$(GCC) $(CFLAGS) -o $@ $^
floatsidf.o:floatsidf.S
	$(GCC) $(CFLAGS) -o $@ $^


libfloat.a:muldi3.o floatsisf.o addsf3.o extendsfdf2.o fixsfsi.o ltsf2.o adddf3.o fp-mul32.o fp-precision.o divdf3.o truncdfsf2.o fabs.o gesf2.o eqsf2.o divsf3.o eqdf2.o ltdf2.o floatsidf.o
	$(AR) $(ARFLAGS)  -o $@ $^

clean:
	rm -rf *.o *.a