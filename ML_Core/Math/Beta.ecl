IMPORT $ AS Utils;
gamma := Utils.gamma;
/**
 * Return the beta value of two real numbers, x and y
 *@param x  the value of the first number
 *@param y  the value of the second number
 *@return   the beta value
 */
EXPORT Beta(REAL8 x, REAL8 y) := FUNCTION
   absx := ABS(x);
   intx := (INTEGER) absx;
   isXRightInt := (absx-intx)<1.0e-9;
   isXLeftInt :=ABS((ROUND(absx)-absx))<1.0e-9;
   isXfail := absx<1.0e-9 OR (x<0 AND (isXRightInt OR isXLeftInt));
   absy := ABS(y);
   inty := (INTEGER) absy;
   isYRightInt := (absy-inty)<1.0e-9;
   isYLeftInt :=ABS((ROUND(absy)-absy))<1.0e-9;
   isYfail := absy<1.0e-9 OR (y<0 AND (isYRightInt OR isYLeftInt));
   bp := gamma(x)*gamma(y)/gamma(x+y);
   bn :=(x+y)*gamma(x+1)*gamma(y+1)/(x*y*gamma(x+y+1));
   b := MAP(
            x>0 AND y>0 => bp,
            isXfail OR isYfail => 9999, //failed, negative or zero ints
            bn //when both x and y negative real numbers
           );
  RETURN b;
END;
