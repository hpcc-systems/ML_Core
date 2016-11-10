IMPORT $ AS Utils;
IMPORT $.^.Constants AS Constants;
PI := Constants.PI;
Poly := Utils.Poly;
/**
 * Stirling's formula
 *@param x the point of evaluation
 *@return evaluation result
 */
EXPORT StirlingFormula(REAL x) :=FUNCTION
   stirCoefs :=[7.87311395793093628397E-4,
                -2.29549961613378126380E-4,
                -2.68132617805781232825E-3,
                3.47222221605458667310E-3,
                8.33333333333482257126E-2];
    REAL8 stirmax := 143.01608;
    REAL8 w := 1.0/x;
    REAL8  y := EXP(x);
    v := 1.0 + w * Poly(w, stirCoefs);
    z := IF(x > stirmax, POWER(x,0.5 * x - 0.25), //Avoid overflow in Math.pow()
                          POWER(x, x - 0.5)/y);
    u := IF(x > stirmax, z*(z/y), z);
    RETURN SQRT(PI)*u*v;
END;
