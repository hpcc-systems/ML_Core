/**
 * The 'double' factorial is defined for ODD n and is the product of
 * all the odd numbers up to and including that number.
 * We are extending the meaning to even numbers to mean the product
 * of the even numbers up to and including that number.
 * Thus DoubleFac(8) = 8*6*4*2
 * We also defend against i < 2 (returning 1.0)
 *@param i the value used in the calculation
 *@return the factorial of the sequence, declining by 2
 */
EXPORT REAL8 DoubleFac(INTEGER2 i) := BEGINC++
  #option pure
  if ( i < 2 )
    return 1.0;
  double accum = (double)i;
  for ( int j = i-2; j > 1; j -= 2 )
    accum *= (double)j;
  return accum;
ENDC++;
