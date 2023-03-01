GCC = /opt/riscv/bin/riscv32-unknown-elf-gcc
OBJ = /opt/riscv/bin/riscv32-unknown-elf-objcopy
B2H = ../common/bin2hex
export objcopy := $(OBJ)
export bin2hex := $(B2H)
code_demo.mem32: main
	../common/bin2hex -w32  main > code_demo.mem32

main:	main.s
	$(GCC) -nostartfiles -O2 -march=rv32ic -mabi=ilp32  -nostdlib -Tlink.ld -o main main.s 

main.s:		main.c
	$(GCC) -nostartfiles -S -march=rv32ic -mabi=ilp32  -nostdlib -Tlink.ld -o main.s main.c

