/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT ML_Core;
IMPORT Python;

IMPORT $.^ AS ML_Core;
IMPORT ML_Core.Analysis AS Analysis;
IMPORT ML_Core.Types AS Types;
IMPORT Python;

Chi2_Result := ML_Core.Types.Chi2_Result;
// Generate Test data

num_wis := 2;
num_samples := 200;
num_variables := 3;
num_classes := 4;

Types.DiscreteField RandomSample(INTEGER x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples * num_variables) + 1;
  SELF.id := (x-1) DIV (num_variables) + 1;
  SELF.number := (x-1) % num_variables + 1;
  SELF.value := (RANDOM()) % (num_classes);
END;

pred := DATASET(num_wis * num_samples * num_variables, RandomSample(COUNTER));
actual := DATASET(num_wis * num_samples * num_variables, RandomSample(COUNTER));

ML_Chi2 := ML_Core.Analysis.FeatureSelection.Chi2(pred,actual);

combNum := RECORD
  Types.NumericField.wi;
  Types.NumericField.id;
  UNSIGNED8 id2;
  SET OF INTEGER values;
  SET OF INTEGER values2;
END;

combWi := RECORD
  Types.NumericField.wi;
  DATASET(combNum) d;
END;

comb := JOIN(pred, actual,
             LEFT.wi = RIGHT.wi and
             LEFT.id = RIGHT.id,
             TRANSFORM({Types.DiscreteField, Integer number2, INTEGER value2},
                       SELF.number2 := RIGHT.number,
                       SELF.value2 := RIGHT.value,
                       SELF := LEFT));

r1 := ROLLUP(GROUP(SORT(comb,wi,number,number2),wi,number,number2), GROUP,
             TRANSFORM(combNum,
                       SELF.wi := LEFT.wi,
                       SELF.id := LEFT.number,
                       SELF.id2 := LEFT.number2,
                       SELF.values := SET(ROWS(LEFT),value),
                       SELF.values2 := SET(ROWS(LEFT),value2)));
                         
r2 := ROLLUP(GROUP(r1,wi), GROUP,
             TRANSFORM(combWi,
                       SELF.wi := LEFT.wi,
                       SELF.d := ROWS(LEFT)));

DATASET(ML_Core.Types.Chi2_Result) sklearn_Chi2_value(DATASET(combWi) a) := EMBED(Python)
  from scipy.stats import chi2_contingency as chi2
  from sklearn.metrics.cluster import contingency_matrix as cm
  result = []
  for workItem in a:
    wi = workItem.wi
    for combination in workItem.d:
      m1 = []
      m2 = []
      for x in combination.values:
        m1.append(x)
      for x in combination.values2:
        m2.append(x)
      c,p,dof,ex = chi2(cm(m1,m2))
      result.append((wi,combination.id, combination.id2, dof, c, p))
  return result
ENDEMBED;

sk_Chi2 := sklearn_Chi2_value(r2);

OUTPUT(DATASET([{ML_Chi2, sk_Chi2}], {DATASET(Chi2_Result) a, DATASET(Chi2_Result) b}))
