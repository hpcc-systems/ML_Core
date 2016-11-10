IMPORT $ AS Utils;
IMPORT $.^.Constants AS Constants;
Poly := Utils.Poly;
Fac := Utils.Fac;
PI := Constants.PI;

/**
 * Return the value of gamma function of real number x
 * The implementation references open source weka gamma function
 * but does not strictly follow it.
 *@param x the input x
 *@return the value of GAMMA evaluated at x
 */
EXPORT gamma(REAL8 x) :=FUNCTION
  P :=[
      1.60119522476751861407E-4,
      1.19135147006586384913E-3,
      1.04213797561761569935E-2,
      4.76367800457137231464E-2,
      2.07448227648435975150E-1,
      4.94214826801497100753E-1,
      9.99999999999999996796E-1];

  Q :=[
      -2.31581873324120129819E-5,
      5.39605580493303397842E-4,
      -4.45641913851797240494E-3,
      1.18139785222060435552E-2,
      3.58236398605498653373E-2,
      -2.34591795718243348568E-1,
      7.14304917030273074085E-2,
      1.00000000000000000320E0];

   absx := ABS(x);
   intx := (INTEGER) absx;
   isRightInt := (absx-intx)<1.0e-9;
   isLeftInt :=ABS((ROUND(absx)-absx))<1.0e-9;
   // x can't be zero or negative integer
   isfail := absx<1.0e-9 OR (x<0 AND (isRightInt OR isLeftInt));

  // x is positive natural numbers
  REAL8 g0 := IF( intx=1 OR intx=2, 1.0, fac(intx-1));

  //x < -6
  REAL8 y := absx * SIN(PI*absx);
  REAL8 g1 := - PI/(y*Utils.StirlingFormula(absx));
  REAL8 g2 := IF(x>6.0, Utils.StirlingFormula(x), g1);

  //abs(x) <6
  z0 := 1.0;
  z1 :=IF(x>3, MAP(//x>3
                  x >5 =>(x-1)*(x-2)*(x-3),
                  x >4 =>(x-1)*(x-2),
                  x >3 =>(x-1),
                  1
                 ), z0);
  REAL8 x1 := IF(x>3, x-(INTEGER)x+2, x);

  //for x1<0
  z2 :=IF(x1<-1 AND x1 >-6,
          MAP(
          x1 <-5=>z1/(x1*(x1+1.0)*(x1+2.0)*(x1+3.0)*(x1+4.0)),
          x1 <-4 =>z1/(x1*(x1+1.0)*(x1+2.0)*(x1+3.0)),
          x1 <-3 =>z1/(x1*(x1+1.0)*(x1+2.0)),
          x1 <-2 => z1/(x1*(x1+1.0)),
          z1/x1
          ), z1);
  x2 := IF(x1<-1 AND x1 >-6.0, x1+(INTEGER)ABS(x1), x1);
  REAL8 w0 := IF(x2<0 AND x2>-1.0E-9, z2/((1.0+0.5772156649015329 * x2)*x2),z2);
  z3 := IF(x2<-1.0E-9, z2/x2, z2);
  x3 := IF(x2<-1.0E-9, x2+1.0, x2);

  //x3>0 and x3<2
  REAL8 w1 := IF(x3<1.0E-9 AND x3>0, z3/((1.0+0.5772156649015329 * x3)*x3),z3);
  z4 := IF(x3<2.0, IF(x3>1.0, z3/x3, z3/(x3*(x3+1.0))), z3);
  x4 := IF(x3<2.0, IF(x3>1.0, x3+1, x3+2), x3);

  x5 := x4-2.0;
  REAL8 u := Poly(x5,P);
  REAL8 v := Poly(x5,Q);
  REAL8 g3 := z4 * u / v;
  REAL8 g := MAP(
          isFail => 9999,//FAIL(99, 'x should not be zero or negative integers'),
          x>1.0e-9 AND ((absx-intx)<1.0e-9 OR ABS((ROUND(absx)-absx))<1.0e-9) => g0,
          //x is big enough
          ABS(x)>=6.0 => g2,
          x2<0 AND x2>-1.0E-9 => w0,
          x3<1.0E-9 AND x3>0 => w1,
          g3);
  RETURN g;
END;
