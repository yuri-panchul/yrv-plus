LD=gcc 
GCC=gcc
OBJ = objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)

CFLAGS=  -I./barebones -I. -c -march=rv32i -mabi=ilp32 -O0 -ffreestanding  -nostartfiles -fPIC


all:libmath.a
	

_divsi3.o:_divsi3.c  
	$(GCC) $(CFLAGS) -o $@ $^

_modsi3.o:_modsi3.c  
	$(GCC) $(CFLAGS) -o $@ $^

_mulsi3.o:_mulsi3.c  
	$(GCC) $(CFLAGS) -o $@ $^

_udivmodsi4.o:_udivmodsi4.c  
	$(GCC) $(CFLAGS) -o $@ $^

_udivsi3.o:_udivsi3.c  
	$(GCC) $(CFLAGS) -o $@ $^

_umodsi3.o:_umodsi3.c
	$(GCC) $(CFLAGS) -o $@ $^

libmath.a:_divsi3.o _modsi3.o _mulsi3.o _udivmodsi4.o _udivsi3.o _umodsi3.o
	$(AR) $(ARFLAGS)  -o $@ $^


clean:
	rm -rf *.o *.a