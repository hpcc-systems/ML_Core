/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ AS ML_Core;
IMPORT ML_Core.Analysis AS Analysis;
IMPORT ML_Core.Types AS Types;
IMPORT Python;

NumericField := ML_Core.Types.NumericField;
DiscreteField := ML_Core.Types.DiscreteField;

// Generate Test data

num_wis := 2;          // Number of work items generated
num_samples := 200;    // Number of samples per work item
num_variables := 3;    // Number of independent classifiers
num_classes := 4;      // Number of classes into which each classifier classifies data

Types.DiscreteField RandomSample(INTEGER x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples * num_variables) + 1;
  SELF.id := (x-1) DIV (num_variables) + 1;
  SELF.number := (x-1) % num_variables + 1;
  SELF.value := (RANDOM()) % (4);
END;

Types.Classification_Scores RandomScore(INTEGER x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples * num_variables * num_classes) + 1;
  SELF.id := (x-1) DIV (num_variables * num_classes) + 1;
  SELF.classifier := ((x-1) DIV (num_classes)) % num_variables + 1;
  SELF.class := (x-1) % num_classes;
  SELF.prob := (RANDOM()%100)/100;
END;

pred := DATASET(num_wis * num_samples * num_variables * num_classes, RandomScore(COUNTER));
actual := DATASET(num_wis * num_samples * num_variables, RandomSample(COUNTER));

// Test the AUC score with random scores for predictions. Should produce values close to 0.5.

ML_Core_AUC := ML_Core.Analysis.Classification.AUC(pred, actual);

// Prepare to compare with sklearn

comb2_L := RECORD
  NumericField.wi;
  NumericField.id;
  NumericField.number;
  DiscreteField.value;
  SET OF REAL8 probs;
END;

probs_L := RECORD
  SET OF REAL8 r;
END;

comb3_L := RECORD
  NumericField.wi;
  NumericField.number;
  SET OF INTEGER values;
  DATASET(probs_L) probs;
END;

comb4_L := RECORD
  NumericField.wi;
  DATASET(comb3_L) d;
END;

comb := JOIN(actual, pred,
             LEFT.wi=RIGHT.wi and
             LEFT.id=RIGHT.id and
             LEFT.number=RIGHT.classifier);

comb2 := ROLLUP(GROUP(comb,wi,id,number),GROUP,
                TRANSFORM(comb2_L,
                          SELF.wi := LEFT.wi,
                          SELF.id := LEFT.id,
                          SELF.number := LEFT.number,
                          SELF.value := LEFT.value,
                          SELF.probs := SET(ROWS(LEFT),prob)));
                          
comb3 := ROLLUP(GROUP(SORT(comb2,wi,number),wi,number),GROUP,
                TRANSFORM(comb3_L,
                          SELF.wi := LEFT.wi,
                          SELF.number := LEFT.number,
                          SELF.values := SET(ROWS(LEFT),value),
                          SELF.probs := TABLE(ROWS(LEFT),{r := probs})));

comb4 := ROLLUP(GROUP(comb3,wi), GROUP,
                TRANSFORM(comb4_L,
                          SELF.wi := LEFT.wi,
                          SELF.d := ROWS(LEFT)));

// compare with sklearn

DATASET(ML_Core.Types.AUC_Result) sklearn_AUC(DATASET(comb4_L) ds) := EMBED(Python)
  from sklearn.preprocessing import label_binarize
  from sklearn.metrics import roc_auc_score
  result = []
  for workItem in ds:
    wi = workItem.wi
    for num in workItem.d:
      number = num.number
      values = []
      probs = []
      for x in num.values:
        values.append(x)
      for x in num.probs:
        temp = []
        for y in x.r:
          temp.append(y)
        probs.append(temp)
      values = label_binarize(values,classes=range(0,len(set(values))))
      aucs = roc_auc_score(values,probs,average=None)
      i = 0
      for r in aucs:
        result.append((wi,number,i,r))
        i+=1
  return result
ENDEMBED;

SK_AUC := sklearn_AUC(comb4);

comparison := JOIN(ML_Core_AUC, SK_AUC,
                   LEFT.wi=RIGHT.wi and
                   LEFT.classifier=RIGHT.classifier and
                   LEFT.class=RIGHT.class,
                   TRANSFORM({REAL8 ML_Core, REAL8 sklearn},
                              SELF.ML_Core := LEFT.auc,
                              SELF.sklearn := RIGHT.auc));

OUTPUT(ML_Core_auc, NAMED('ML_Core'));
OUTPUT(SK_auc, NAMED('sklearn'));
OUTPUT(comparison, NAMED('comparison'));
