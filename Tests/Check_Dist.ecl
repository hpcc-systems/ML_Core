IMPORT $.^.Math.Distributions AS Distributions;
IMPORT $.^ AS ML_Core;
IMPORT Python;
REAL8 scipy_dist_cdf(REAL8 x, REAL8 df, INTEGER dist) := EMBED(Python)
  import scipy;
  import scipy.stats;
  if dist == 1:
      ret_val = scipy.stats.norm.cdf(x);
  elif dist == 2:
      ret_val = scipy.stats.t.cdf(x, df);
  else:
      ret_val = scipy.stats.chi2.cdf(x, df);
  return ret_val;
ENDEMBED;
REAL8 scipy_dist_ppf(REAL8 x, REAL8 df, INTEGER dist) := EMBED(Python)
  import scipy;
  import scipy.stats;
  if dist==1:
      ret_val = scipy.stats.norm.ppf(x);
  elif dist == 2:
      ret_val = scipy.stats.t.ppf(x, df);
  else:
      ret_val = scipy.stats.chi2.ppf(x, df);
  return ret_val;
ENDEMBED;
REAL8 diff_tolerance(STRING4 test) := CASE(test,
                                    'TPPF'  => 0.00005,
                                    'XCDF'  => 0.00001,
                                    'XPPF'  => 0.005,
                                    0.0000001);

prob_values := [0.000001, 0.00001, 0.0001, 0.001, 0.01, 0.025, 0.05, 0.5,
                0.95, 0.975, 0.99, 0.999, 0.9999, 0.99999, 0.999999];
dist_values := [-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 1500];
df_values := [1,2,3,4,5,9,10,11,19,20,30,31,32,50,55,99,100,300,1000,10000];
SET OF STRING4 test := ['NPPF', 'NCDF', 'TPPF', 'TCDF', 'XPPF', 'XCDF'];
SET OF STRING4 inv_test := ['NPPF', 'TPPF', 'XPPF'];
Work := RECORD
  UNSIGNED4 df;
  REAL8 prob;
  REAL8 ecl_ppf;
  REAL8 scipy_ppf;
  REAL8 ppf_diff;
  REAL8 dist;
  REAL8 ecl_cdf;
  REAL8 scipy_cdf;
  REAL8 cdf_diff;
END;
REAL8 abs_max_abs(REAL8 a, REAL8 b) := ABS(MAX(ABS(a),ABS(b)));
BOOLEAN fixed(REAL8 a, REAL8 b) := ABS(a-b)<1.0 AND ABS(a)<1 AND ABS(b)<1;
REAL8 divisor(REAL8 a, REAL8 b) := IF(fixed(a,b), 1.0, abs_max_abs(a,b));
REAL8 calc_err(REAL8 a, REAL8 b) := ABS(a-b)/divisor(a,b);
BOOLEAN check_err(REAL8 a, REAL8 b, REAL8 t) := t>calc_err(a,b);
Work run(UNSIGNED c, INTEGER d) := TRANSFORM
  prob := prob_values[((c-1) % COUNT(prob_values)) + 1];
  dist := dist_values[((c-1) % COUNT(prob_values)) + 1];
  df := IF(d=1, 0, df_values[((c-1) DIV COUNT(prob_values)) + 1]);
  SELF.df := df;
  SELF.prob := prob;
  SELF.dist := dist;
  SELF.ecl_ppf := CHOOSE(d,
                     Distributions.Normal_PPF(prob),
                     Distributions.T_PPF(prob, df),
                     Distributions.Chi2_PPF(prob, df));
  SELF.scipy_ppf := scipy_dist_ppf(prob, df, d);
  SELF.ecl_cdf := CHOOSE(d,
                   Distributions.Normal_CDF(dist),
                   Distributions.T_CDF(dist,df),
                   Distributions.Chi2_CDF(dist,df));
  SELF.scipy_cdf := scipy_dist_cdf(dist, df, d);
  SELF.cdf_diff := ABS(SELF.ecl_cdf-SELF.scipy_cdf);
  SELF.ppf_diff := ABS(SELF.ecl_ppf-SELF.scipy_ppf);
END;
Report := RECORD
  STRING4 test;
  BOOLEAN OK;
  UNSIGNED4 df;
  REAL8 inp_value;
  REAL8 ecl_value;
  REAL8 py_value;
  REAL8 diff;
END;
Report makeReport(Work w, UNSIGNED c) := TRANSFORM
  REAL8 tv := diff_tolerance(test[c]);
  cdf_OK := ABS(w.ecl_cdf-w.scipy_cdf) <= tv;
  ppf_ok := check_err(w.ecl_ppf, w.scipy_ppf, tv);
  SELF.test := test[c];
  SELF.df := w.df;
  SELF.OK := IF(SELF.test IN inv_test, ppf_OK, cdf_OK);
  SELF.inp_value := IF(SELF.test IN inv_test, w.prob, w.dist);
  SELF.ecl_value := IF(SELF.test IN inv_test, w.ecl_ppf, w.ecl_cdf);
  SELF.py_value := IF(SELF.test IN inv_test, w.scipy_ppf, w.scipy_cdf);
  SELF.diff := IF(SELF.test IN inv_test, w.ppf_diff, w.cdf_diff);
END;
ts1 := DATASET(COUNT(prob_values), run(COUNTER, 1));
ts2 := DATASET(COUNT(prob_values)*COUNT(df_values), run(COUNTER,2));
ts3 := DATASET(COUNT(prob_values)*COUNT(df_values), run(COUNTER,3));
r1 := NORMALIZE(ts1, 2, makeReport(LEFT, COUNTER));
r2 := NORMALIZE(ts2, 2, makeReport(LEFT, 2+COUNTER));
r3 := NORMALIZE(ts3, 2, makeReport(LEFT, 4+COUNTER));
df_cat(UNSIGNED4 df) := MAP(df=0      => '          ',
                            df <=10   => '   1,   10',
                            df <=100  => '  10,  100',
                            df <=1000 => ' 100, 1000',
                                         '1000+     ');
rpt :=TABLE(r1+r2+r3, {test,
                    STRING10 cat:=df_cat(df),
                    tested:=COUNT(GROUP),
                    Incorrect:=SUM(GROUP, IF(OK, 0, 1))},
            test, df_cat(df), FEW, UNSORTED);
errors := SORT((r1+r2+r3)(NOT OK), test, inp_value, df);
error_actions := PARALLEL(
    OUTPUT(SORT(r1, OK, test, df, inp_value), ALL, NAMED('Details_r1')),
    OUTPUT(SORT(r2, OK, test, df, inp_value), ALL, NAMED('Details_r2')),
    OUTPUT(SORT(r3, OK, test, df, inp_value), ALL, NAMED('Details_r3')),
    OUTPUT(SORT(rpt, test, cat), ALL, NAMED('Summary_Errors')),
    OUTPUT(TOPN(errors, 100, -diff), ALL, NAMED('Largest_Errors')),
    OUTPUT(TOPN(errors, 100, diff), ALL, NAMED('Smallest_Errors'))
);
passed := SEQUENTIAL(OUTPUT(SORT(rpt, test, cat), NAMED('Summary')));

EXPORT Check_Dist := IF(EXISTS(errors), error_actions, passed);
