	.text
	
	la	a0, var
loop:
	sw	t1, (a0)
	addi	t1, t1, 5
	b	loop

	.data

var:	.word
