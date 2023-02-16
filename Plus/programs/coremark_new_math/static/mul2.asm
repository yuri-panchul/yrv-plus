# P = MP x MC

# x5 = P , x4 = MP, x3 = MC
# x7 = 00000000_000000000_00000000_000000001
# x8 = 32'b0

#x10 ->  t0
#x7 -> t1
#x8 -> t2 
# x9 -> t3
# x11 -> t4
# x5 -> t5

.text

	j    start

_smult:
	addi t0, zero, 16
	addi t1, zero, 1
	add  t2, zero,  zero
	
	srli  t6, a0, 31
	slli  t6,t6,31
	beqz  t6, POS1
	neg    a0
POS1:
	
	add   t6,a1,t6
	srli  t6,t6,31
	
	sli  t6,t6,31
	
	slli a0,a0,1
	srli a0,a0,1

	slli a1,a1,1
	srli a1,a1,1
	
			
	jal zero, SWHEXP

SWHLOOP:	
	and t3, a0, t1
	beq t3, t1, SMULT
	
SENDIF:
	addi t2,t2, 1
	slli t1, t1, 1
	j SWHEXP
	
SMULT:
	sll  t4, a1, t2
	add  t5, t5, t4
	j SENDIF
	
SWHEXP: 
	blt t2, t0, SWHLOOP
	mv a0,t5
	beqz  t6, POSITIVE
	neg   a0,a0

POSITIVE:
	ret 
	

#------------------------------

_umult:
	addi t0, zero, 16
	addi t1, zero, 1
	add  t2, zero,  zero
	
	jal zero, WHEXP

WHLOOP:	
	and t3, a0, t1
	beq t3, t1, MULT
	
ENDIF:
	addi t2,t2, 1
	slli t1, t1, 1
	j WHEXP
	
MULT:
	sll  t4, a1, t2
	add  t5, t5, t4
	j ENDIF
	
WHEXP: 
	blt t2, t0, WHLOOP
	mv a0,t5
	ret 

#------------------------------

start:
	li   a0, -5
	li   a1, -5
	call _smult

END:
		