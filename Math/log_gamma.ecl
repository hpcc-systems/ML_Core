/**
 * Return the value of the log gamma function of the absolute value
 * of X.
 * A wrapper for the standard C lgamma function.  Avoids the race
 * condition found on some platforms by taking the absolute value of the
 * of the input argument.
 *@param x the input x
 *@return the value of the log of the GAMMA evaluated at ABS(x)
 */
EXPORT REAL8 log_gamma(REAL8 x) := BEGINC++
  #option pure
  #include <math.h>
  return lgamma(fabs(x));
ENDC++;
