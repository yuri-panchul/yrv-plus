/* Counters for fp operation with variable precision */

#include <sys/types.h>
#include "fp-soft-variable.h"

#define MAX32PRECISION 24
unsigned int fp_precision = MAX32PRECISION-1;

#define COUNTFOROPERATOR(operator) 											\
  long long fp##operator##_count[MAX32PRECISION]; 							\
  void fpInc##operator() {   fp##operator##_count[fp_precision]++;} 		\
  long long fpGet##operator##Count (int index){return fp##operator##_count[index];}
COUNTFOROPERATOR (sub);
COUNTFOROPERATOR (add);
COUNTFOROPERATOR (mul);
#undef COUNTFOROPERATOR

long long fpGetFmulCount (int index)
{
  return fpmul_count[index];
}

void fpSetPrecision (int mantissa_bits)
{
  fp_precision = mantissa_bits;
}

int fpGetPrecision()
{
  return fp_precision;
}



