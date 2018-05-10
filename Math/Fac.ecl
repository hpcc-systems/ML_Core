/**
  * Factorial function, (i)(i-1)(i-2)...(2)
  * @param i the input value.
  * @return the factorial i!.
  **/
EXPORT REAL8 Fac(UNSIGNED2 i) := BEGINC++
  #option pure
  double accum = 1.0;
  for ( int j = 2; j <= i; j++ )
    accum *= (double)j;
  return accum;
ENDC++;
