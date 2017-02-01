// Compare gamma and the incomplete gamma functions against the
//implementations found in the Python numpy and scipy packages.
IMPORT $.^ AS ML_Core;
IMPORT ML_Core.Math;
IMPORT Python;

REAL8 scipy_gamma(REAL8 x) := EMBED(Python)
  import scipy;
  import scipy.special;
  return scipy.special.gamma(x);
ENDEMBED;
REAL8 scipy_lowerGamma(REAL8 x, REAL8 z) := EMBED(Python)
  import scipy;
  import scipy.special;
  return scipy.special.gamma(x) * scipy.special.gammainc(x, z);
ENDEMBED;
REAL8 scipy_upperGamma(REAL8 x, REAL8 z) := EMBED(Python)
  import scipy;
  import scipy.special;
  return scipy.special.gamma(x) * scipy.special.gammaincc(x, z);
ENDEMBED;

SET OF REAL8 tv := [0.5, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 3.1,
                    3.5, 4.0, 4.25, 4,5, 5.0, 5.5, 6.0, 6.5,
                    7.0, 7.4, 8.0, 8.6, 9.0, 9.5, 10.0, 10.5,
                    50.0, 100.5];
SET OF REAL8 sv := [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 4.0, 5.25, 25];
REAL8 epsilon := 0.000000001;
Work1 := RECORD
  REAL8 x;
  REAL8 z;
  REAL8 g;
  REAL8 l;
  REAL8 u;
  REAL8 g_diff;
  REAL8 l_diff;
  REAL8 u_diff;
  REAL8 py_g;
  REAL8 py_l;
  REAL8 py_u;
END;

Work1 makeT(UNSIGNED ts) := TRANSFORM
  t := ((ts-1) % COUNT(tv)) + 1;
  s := ((ts-1) DIV COUNT(tv)) + 1;
  REAL8 x := tv[t];
  REAL8 z := sv[s];
  SELF.x := x;
  SELF.z := z;
  SELF.g := Math.gamma(x);
  SELF.l := math.lowerGamma(x, z);
  SELF.u := Math.upperGamma(x, z);
  SELF.py_g := scipy_gamma(x);
  SELF.py_l := scipy_lowerGamma(x,z);
  SELF.py_u := scipy_upperGamma(x,z);
  g_denom := MAX(scipy_gamma(x), Math.gamma(x));
  g_abs_diff := ABS(scipy_gamma(x) - Math.gamma(x));
  SELF.g_diff := IF(g_abs_diff/g_denom < epsilon, 0, g_abs_diff);
  l_denom := MAX(scipy_lowerGamma(x, z), Math.lowerGamma(x, z));
  l_abs_diff := ABS(scipy_lowerGamma(x, z) - Math.lowerGamma(x, z));
  SELF.l_diff := IF(l_abs_diff/l_denom < epsilon, 0, l_abs_diff);
  u_denom := MAX(scipy_upperGamma(x, z), MAth.upperGamma(x, z));
  u_abs_diff := ABS(scipy_upperGamma(x, z) - Math.upperGamma(x, z));
  SELF.u_diff := IF(u_abs_diff/u_denom < epsilon, 0, u_abs_diff);
END;
STRING range_cat(REAL8 x, REAL8 z)
        := MAP(x <= 5   => '000-005',
               x <= 25  => '005-025',
               x <= 75  => '025-075',
               '075-999')
         + ' x; '
         + MAP(z = 0.0      => '000-000',
               z <= 2.0     => '000-002',
               z <= 5.0     => '002-005',
               '005-025');
STRING cat(REAL8 x, REAL8 z) :=
           IF(z < x + 1, 'z low side | ', 'z high side| ')
         + MAP(z = 0            => 'zero z   | ',
               z = (INTEGER)z   => 'int z    | ',
               'float z  | ')
         + MAP(x = (INTEGER)x   => 'int x  | ',
               x <=25           => 'low x  | ',
               'high x | ');

test_set := DATASET(COUNT(tv)*COUNT(sv), makeT(COUNTER));
bad_result := test_set(g_diff<>0 OR u_diff<>0 OR l_diff<>0);
test_sum := TABLE(test_set,
                 {STRING c:=cat(x, z),
                  Good_u:=SUM(GROUP, IF(u_diff=0, 1, 0)),
                  Bad_u:=SUM(GROUP, IF(u_diff=0, 0, 1)),
                  Good_l:=SUM(GROUP, IF(l_diff=0, 1, 0)),
                  Bad_l:=SUM(GROUP, IF(l_diff=0, 0, 1)),
                  Good_g:=SUM(GROUP, IF(g_diff=0, 1, 0)),
                  Bad_g:=SUM(GROUP, IF(g_diff=0, 0, 1))},
                 cat(x, z), FEW, UNSORTED);

Passed_Action := OUTPUT('Passed', NAMED('Status'), OVERWRITE);
Failed_Action := SEQUENTIAL(
   OUTPUT('Failed', NAMED('Status'), OVERWRITE)
  ,OUTPUT(SORT(test_sum, c), NAMED('Test_Compare_Summary'))
  ,OUTPUT(TOPN(test_set, 25, g_diff), NAMED('Least_Diff_Gamma'))
  ,OUTPUT(TOPN(test_set, 25, -g_diff), NAMED('Most_Diff_Gamma'))
  ,OUTPUT(TOPN(test_set, 25, u_diff), NAMED('Least_Diff_Upper'))
  ,OUTPUT(TOPN(test_set, 25, -u_diff), NAMED('Most_Diff_Upper'))
  ,OUTPUT(TOPN(test_set, 25, l_diff), NAMED('Least_Diff_Lower'))
  ,OUTPUT(TOPN(test_set, 25, -l_diff), NAMED('Most_Diff_Lower'))
);


EXPORT Validate_Gammas := IF(EXISTS(bad_result),
                             Failed_Action,
                             Passed_Action);
