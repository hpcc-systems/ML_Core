// Compare Beta against the scipy implementation of Beta for validation
//We only expose the Beta at this point, but test is intended to be
//expanded to add the incomplete (lower) Beta.
IMPORT ML_Core;
IMPORT ML_Core.Math;
IMPORT Python;
REAL8 scipy_beta(REAL8 x, REAL8 y) := EMBED(Python)
  import scipy;
  import scipy.special;
  return scipy.special.beta(x,y);
ENDEMBED;
//Test design cases
// 1) Two positive integers, both under 171 and sum under 171
// 2) Two positive integers, at least one or sum over 171
// 3) Two positive reals, both under 171 and sum under 171
// 4) two positive reals, at least one or sum over 171
// 5) one negative integer
// 6) two negative integers
// 7) one negative real
// 8) two negative real values
// 9) two positives, one > 1e6
Layout_Test_Values := RECORD
  REAL8 x;
  REAL8 y;
  UNSIGNED1 test_case;
END;
test_set := DATASET([{              1.0,              1.0, 1},
                     {            150.0,             15.0, 1},
                     {             15.0,            150.0, 1},
                     {            120.0,             60.0, 2},
                     {            900.0,              2.0, 2},
                     {              2.0,            200.0, 2},
                     {              3.25,             7.6, 3},
                     {              7.6,             3.25, 3},
                     {              0.5,            200.5, 4},
                     {            200.3,              0.5, 4},
                     {             -2.0,              0.9, 5},
                     {           -200.0,            100.0, 5},
                     {            -10.0,            -20.0, 6},
                     {            -19.2,             51.0, 7},
                     {             13.3,            -19.2, 7},
                     {           -190.2,            -87.9, 8},
                     {        1000000.0,        0.00001,   9},
                     {      100000000.0,              5.0, 9},
                     {      100000017.0,             13.0, 9},
                     {   100000000000.0,      100000000.5, 9},
                     {      100000567.0,              7.0, 9},
                     {             10.0,     1000005670.0, 9}],
                    Layout_Test_Values);
REAL8 epsilon := 0.000001;
Layout_Test_Result := RECORD
  REAL8 ecl_value;
  REAL8 sci_value;
  BOOLEAN pass;
  UNSIGNED1 test_case;
  REAL8 x;
  REAL8 y;
END;
Layout_Test_Result test_func(Layout_Test_Values tv) := TRANSFORM
  ecl_value := Math.Beta(tv.x, tv.y);
  sci_value := scipy_beta(tv.x, tv.y);
  abs_diff :=  ABS(SELF.ecl_value - SELF.sci_value);
  abs_ratio := abs_diff/MAX(ABS(ecl_value), ABS(sci_value));
  SELF.ecl_value := ecl_value;
  SELF.sci_value := sci_value;
  SELF.pass := SELF.ecl_value=SELF.sci_value OR abs_ratio <= epsilon;
  SELF := tv;
END;
rslt := PROJECT(test_set, test_func(LEFT));

EXPORT Validate_Betas := OUTPUT(rslt);
