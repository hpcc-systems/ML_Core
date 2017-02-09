/**
 * Return the lower incomplete gamma value of two real numbers,
 *  x and y
 *@param x  the value of the first number
 *@param y  the value of the second number
 *@return   the lower incomplete gamma value
 */
EXPORT REAL8 lowerGamma(REAL8 x, REAL8 y) := BEGINC++
  #option pure
  #include <math.h>
  double n,r,s,ga,t,gin;
  int k;
  if ((x < 0.0) || (y < 0)) return 0;
  n = -y+x*log(y);
  if (y == 0.0) {
    gin = 0.0;
    return gin;
  }
  if (y <= 1.0+x) {
    s = 1.0/x;
    r = s;
    for (k=1;k<=100;k++) {
      r *= y/(x+k);
      s += r;
      if (fabs(r/s) < 1e-15) break;
    }
  gin = exp(n)*s;
  }
  else {
    t = 0.0;
    for (k=100;k>=1;k--) {
      t = (k-x)/(1.0+(k/(y+t)));
    }
    ga = tgamma(x);
    gin = ga-(exp(n)/(y+t));
  }
  return gin;
ENDC++;
