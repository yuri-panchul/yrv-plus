/* 
  32 bits mask, values & prototypes

  https://en.wikipedia.org/wiki/Single-precision_floating-point_format
  IEEE floating point number 32 bits (float) number format :
   3         2         1
  10987654321098765432109876543210 
  SEEEEEEEEMMMMMMMMMMMMMMMMMMMMMMM
  Sign = 1 bit
   Exponent = 8 bits
           Mantissa = 23 bits
  https://en.wikipedia.org/wiki/Double-precision_floating-point_format
  IEEE floatint point number 64 bits (double) number format :
     6         5         4         3         2         1
  3210987654321098765432109876543210987654321098765432109876543210 
  SEEEEEEEEEEEMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
  Sign = 1 bit
   Exponent = 11 bits
              Mantissa = 52 bits

  This library _is not_ IEEE compliant !

*/
#define POSITIVE_INFINITY       0x7F800000
#define NEGATIVE_INFINITY       0xFF800000
#ifndef NAN
#define NAN                     0x7FC00000
#endif
#define POSITIVE_ZERO           0x00000000
#define NEGATIVE_ZERO           0x80000000

#define SHORT_SIGNBIT_MASK          0x8000
#define LONG32_SIGNBIT_MASK     0x80000000
#define SHORT_EXPONENT_MASK         0x7F80
#define LONG_EXPONENT_MASK      0x7F800000
#define MANTISSA32_MASK           0x7FFFFF
#define MANTISSA64_MASK     0xFFFFFFFFFFFF
#define NO_SIGN                 0x7FFFFFFF

#define HIDDEN32                (1ul << 23)
#define HIDDEN64                (1ull << 52)

#define SHORT_SHIFT             16
#define MAX_EXPONENT            128
#define EXPONENT_OVERFLOW       254
#define EXPONENT_SHIFT          7
#define MANTISSA_BITS           24
#define EXCESS                  126

#if 0
#define LSHIFT(a,s) 	{a = (a >> s) | !!(a & (((int) 1 << s) - 1)); }
#else
#define LSHIFT(a,s) 	do{a = (a >> s) ;}while(0)
#endif
#define SIGN32(fp)        (((fp) >> 31) & 1)
#define MANT32(fp)        (((fp) & MANTISSA32_MASK) | HIDDEN32)
#define EXP32(fp)         (((fp) >> 23) & 0x0FF)
#define PACK32(s,e,m)     (((s) << 31) | ((e & 0x0FF) << 23) | (m & MANTISSA32_MASK))
#define IMPLICIT32_1 	   (1<< (23))

#define SIGN64(fp)        (((fp) >> 63) & 1)
#define MANT64(fp)        (((fp) & MANTISSA64_MASK) | HIDDEN64)
#define EXP64(fp)         (((fp) >> 52) & 0x07FF)
#define PACK64(s,e,m)     (((s) << 63) | ((e) << 52) | (m & MANTISSA64_MASK))

#define printBinVariable(value, len)	\
do										\
{										\
  printf ("%10s", #value);				\
  printBin(value, len);					\
  printf ("\n");						\
}  while(0)

#define printFPBinMantissa(value)		\
do										\
{										\
	printBinVariable(value, 24);        \
}  while(0)

typedef union {                 /* Multiple view for a 32 bits FP number */
  float f;                      /* X86 version */
  int i;
} float_cast;

typedef union {					/* Multiple view for a 64 bits FP number */
  double d;
  __uint64_t i;
} double_cast;

#define PrF(V)   printFloat  (V, #V)
void printFloat(float_cast tmp, char *name);
#define PrD(V)   printDouble (V, #V)
void printDouble(double_cast tmp, char *name);
void printBin(long unsigned value, int len);

float    __mulsf3(float a, float b);
__uint64_t mulsf3_classical(__uint64_t a1, __uint64_t a2);

float    __addsf3(float a, float b);
__uint64_t addsf3_classical(__uint64_t a1, __uint64_t a2);
__uint64_t fpaddparts(__uint64_t a, __uint64_t b);

float    __subsf3(float a, float b);
__uint64_t subsf3_classical(__uint64_t a1, __uint64_t a2);

void fpSetPrecision (int mantissa_bits);
void fpInitCount();
int fpGetPrecision();

#define COUNTFOROPERATOR(operator)	\
extern long long fp##operator##_count[];\
void fpInc##operator();              \
long long fpGet##operator##Count (int index);

COUNTFOROPERATOR (add);
COUNTFOROPERATOR (sub);
COUNTFOROPERATOR (mul);
#undef COUNTFOROPERATOR

extern int fpPrecision;

