# P = MP x MC
# x5 = P , x4 = MP, x3 = MC
# x7 = 00000000_000000000_00000000_000000001
# x8 = 32'b0


.text

	
	li   x4, 100
	li   x3, 123
_mult:
	addi x10, x0, 16
	addi x7, x0, 1
	add  x8, x0,  x0
	
	jal x0, WHEXP

WHLOOP:	
	and x9, x4, x7
	beq x9, x7, MULT
	
ENDIF:
	addi x8,x8, 1
	slli x7, x7, 1
	beq  x0, x0 WHEXP
	
MULT:
	sll  x11, x3, x8
	add  x5, x5, x11
	beq  x0, x0, ENDIF
	
WHEXP: 
	blt x8, x10, WHLOOP
		