.section .text
.global __modsi3

__modsi3:
#uint32_t bitwise_division (uint32_t dividend, uint32_t divisor)
#{
#    uint32_t quot, rem, t;
#    int bits_left = CHAR_BIT * sizeof (uint32_t);
#
#    quot = dividend;
#    rem = 0;
#    do {
#            // (rem:quot) << 1
#            t = quot;
#            quot = quot + quot;
#            rem = rem + rem + (quot < t);
#
#            if (rem >= divisor) {
#                rem = rem - divisor;
#                quot = quot + 1;
#            }
#            bits_left--;
#    } while (bits_left);
#    return quot;
#}

# quot -> t0
# rem -> t1
# t ->t2
# bit-left -> t3

    li t3,  32
    li t5,1
    li t6,0

    bgtz a0, A0_POS
    neg a0,a0
    addi t6, t6, 1
A0_POS:

    bgtz a1, A1_POS
    neg a1,a1
    addi t6, t6, 1
A1_POS:
    mv  t0, a0
    add t1, zero, zero
DO:
    mv   t2, t0 # t = quot;
    add  t0,t0,t0 # quot = quot + quot;
    sltu t4, t0,t2
    add  t1,t1,t1
    add  t1,t1,t4

    blt  t1, a1, END_THEN #if (rem >= divisor) {
    sub  t1,t1,a1
    addi t0,t0,1
END_THEN:
    sub   t3,t3,t5
    bnez  t3, DO
    sub   t6,t6,t5
    bnez  t6, POSITIVE
    neg   t0,t0
POSITIVE:
    mv    a0,t0
    ret
