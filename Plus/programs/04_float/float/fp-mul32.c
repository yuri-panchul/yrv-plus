/* Multiply 2 32 bits floating point numbers without multiplier */

#include <sys/types.h>

#include "fp-soft-variable.h"

__uint64_t fpmulparts(__uint64_t a1, __uint64_t a2)
{
  __uint64_t mult = a2;
  __uint64_t total = 0;
  __uint64_t ret;
  int bit, diff, precision;

  precision = fpGetPrecision();
  diff = MANTISSA_BITS - precision;
  mult <<= diff;
  a1 >>= diff;
  for (bit = diff; bit < MANTISSA_BITS; bit++)
    {
      if (a1 & 0x1)
        {
          total += mult;
        }
      mult <<= 1;
      a1 >>= 1;
    }
  ret = total>>SHORT_SHIFT;
  return ret;
}

__uint64_t mulsf3_classical(__uint64_t a1, __uint64_t a2)
{
  __uint64_t result;
  int sign, exp, tmp;
  
  fpIncmul();  
  sign = ((a1>>SHORT_SHIFT^a2>>SHORT_SHIFT))&SHORT_SIGNBIT_MASK; // Calculate the sign
  exp = SHORT_EXPONENT_MASK & (a1>>SHORT_SHIFT);   //take the exponent for each operand
  tmp = SHORT_EXPONENT_MASK & (a2>>SHORT_SHIFT);
  
  if(!a1 || !a2)
    return 0;
  a1 = MANT32(a1);
  a2 = MANT32(a2);
  exp -= EXCESS<<EXPONENT_SHIFT;
  exp += tmp;
  result = fpmulparts(a1, a2);
  //normalize and round the result
  if (result & LONG32_SIGNBIT_MASK)
    {
      /* round */
      result += 0x80ul;
      result >>= (EXPONENT_SHIFT+1);
    }
  else
    {
      result += 0x40ul;
      result >>= EXPONENT_SHIFT;
      exp -= 1<<EXPONENT_SHIFT;
    }
  if (result & (HIDDEN32<<1))
    {
      result >>= 1;
      exp += 1<<EXPONENT_SHIFT;
    }
  result &= ~HIDDEN32;
  //put all the parts together again
  result |= ((long)(sign | exp)<<SHORT_SHIFT);
  return result;
}

float __mulsf3(float a, float b)
{
  float_cast af, bf, cf;

  af.f = a;
  bf.f = b;
  cf.i = mulsf3_classical(af.i, bf.i);
  return cf.f;
}
