/**
 * Evaluate a polynomial from a set of co-effs. Co-effs 1 is
 * assumed to be the HIGH order of the equation.
 * Thus for ax^2+bx+c - the set would need to be Coef := [a,b,c];
 *@param x the value of x in the polynomial
 *@param Coeffs a set of coefficients forthe polynomial. The ALL
 *              set is considered to be all zero values
 *@return value of the polynomial at x
 */
EXPORT REAL8 Poly(REAL8 x, SET OF REAL8 Coeffs) := BEGINC++
  #option pure
  if (isAllCoeffs)
    return 0.0;
  int num = lenCoeffs / sizeof(double);
  if ( num == 0 )
    return 0.0;
  const double * cp = (const double *)coeffs;
  double tot = *cp++;
  while ( --num )
    tot = tot * x + *cp++;
  return tot;
ENDC++;
