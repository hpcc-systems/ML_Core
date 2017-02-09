/**
 * Return the value of gamma function of real number x
 * A wrapper for the standard C tgamma function.
 *@param x the input x
 *@return the value of GAMMA evaluated at x
 */
EXPORT REAL8 gamma(REAL8 x) := BEGINC++
  #option pure
  #include <math.h>
  return tgamma(x);
ENDC++;
