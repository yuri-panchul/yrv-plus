.section .text.init
.global _run
.global redo
.global digit

           .equ  mie,    0x304
           .equ  mtvec,  0x305
           .equ  mcause, 0x342
           .equ  iobase, 0xffff0     # i/o at 0xffff0000

_run:
redo:
loop:

.cfi_startproc
.cfi_undefined ra
.option push
.option norelax
	  la gp, __global_pointer$
.option pop
	  la sp, __stack_top
	  add s0, sp, zero
	  jal zero, main
.cfi_endproc
           
           beq   zero, zero, loop
                    
.section .data     
segtab:    .word 0x8692cf81          # 3210  segment drive act-low
           .word 0x8fa0a4cc          # 7654
           .word 0xe0888480          # BA98
           .word 0xb8b0c2b1          # FEDC

digit:     .word 0x01020304

