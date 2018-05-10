/**
  * Compute the double factorial.
  * The double factorial is defined for odd n as the product of
  * all the odd numbers up to and including that number.
  * <p>For even numbers it is the product
  * of the even numbers up to and including that number.
  * <p>Thus DoubleFac(8) = 8*6*4*2.
  * <p>IF i < 2, the value 1 is returned.
  * @param i the input value.
  * @return the numeric result.
  **/
EXPORT REAL8 DoubleFac(INTEGER2 i) := BEGINC++
  #option pure
  if ( i < 2 )
    return 1.0;
  double accum = (double)i;
  for ( int j = i-2; j > 1; j -= 2 )
    accum *= (double)j;
  return accum;
ENDC++;
