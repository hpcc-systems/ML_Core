IMPORT $ AS Math;;
gamma := Math.gamma;
log_gamma := Math.log_gamma;
MAXGAM := 171;
ASYMP := 1000000; //1e6
/**
 * Return the beta value of two positive real numbers, x and y
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
   use_b_log := x+y>MAXGAM OR x>MAXGAM OR y>MAXGAM;
   b_log := log_gamma(x) + log_gamma(y) - log_gamma(x+y);
   use_y_asymp := x > ASYMP AND x > ASYMP * y;
   y_asymp := log_gamma(y) - y*LN(x) + y*(1-y)/(2*x)
            + y*(1-y)*(1-2*y)/(12*x*x)
            - y*y*(1-y)*(1-y)/(12*x*x*x);
   use_x_asymp := y > ASYMP AND y > ASYMP * x;
   x_asymp := log_gamma(x) - x*LN(y) + x*(1-x)/(2*y)
            + x*(1-x)*(1-2*x)/(12*y*y)
            - x*x*(1-x)*(1-x)/(12*y*y*y);
   // choose the right definition to use
   b := MAP(x>0 AND y>0 AND use_y_asymp => EXP(y_asymp),
            x>0 AND y>0 AND use_x_asymp => EXP(x_asymp),
            x>0 AND y>0 AND use_b_log => EXP(b_log),
            x>0 AND y>0 => bp,
            isXfail OR isYfail => 9999, //failed, negative or zero ints
            bn //when both x and y negative real numbers
           );
  RETURN b;
END;
