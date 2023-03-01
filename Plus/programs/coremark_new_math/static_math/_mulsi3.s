.section .text
.global __mulsi3

__mulsi3:
   li t0, 0
next_digit:
   andi t1, a1, 1           # is rightmost bit 1?
   srai a1, a1, 1

   beq  t1, zero, skip      # if right most bit 0, don't add
   add  t0, t0, a0
skip:
   slli a0, a0, 1           # double first argument
   bne  a1, zero, next_digit
   mv   a0, t0
   ret
