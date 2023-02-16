.section .text
.global __mulsi3

__mulsi3:
	mv t0, zero
	mv t1, zero
	mv t2, zero
	mv t3, zero
	mv t4, zero
	mv t5, zero
	mv t6, zero

	addi t0, x0, 16
	addi t1, x0, 1
	add  t2, x0,  x0

	jal x0, WHEXP

WHLOOP:
	and t3, a0, t1
	beq t3, t1, MULT

ENDIF:
	addi t2,t2, 1
	slli t1, t1, 1
	beq  x0, x0, WHEXP

MULT:
	sll  t4, a1, t2
	add  t5, t5, t4
	beq  x0, x0, ENDIF

WHEXP:
	blt t2, t0, WHLOOP
	mv a0, t5
	ret
