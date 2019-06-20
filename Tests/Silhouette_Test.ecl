/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ AS ML_Core;
IMPORT Python;

// Generate test data

Labels := ML_Core.Types.ClusterLabels;
NumericField := ML_Core.Types.NumericField;

num_wis := 10;          // Number of work-items the generated data will have
num_samples := 200;     // Number of samples per work item
num_dimensions := 3;    // Number of dimensions of the points in space
num_labels := 4;        // Number of cluster labels produced

Labels GenerateLabel(UNSIGNED x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples) + 1;
  SELF.id := x;
  SELF.label := RANDOM() % num_labels;
END;

NumericField GenerateSample(UNSIGNED x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples * num_dimensions) + 1;
  SELF.id := (x-1) DIV (num_dimensions) + 1;
  SELF.number := (x-1) % num_dimensions + 1;
  SELF.value := (RANDOM() % 100)/100;
END;

samples := DATASET(num_wis * num_samples * num_dimensions, GenerateSample(COUNTER));
PredLabels := DATASET(num_wis * num_samples, GenerateLabel(COUNTER));

//Find Silhouette Score

ML_Sil_Score := ML_Core.Analysis.Clustering.SilhouetteScore(samples, PredLabels);

// Compare with Scikit Learn

CombinedFields := RECORD
  NumericField.wi;
  NumericField.id;
  Labels.label;
  SET OF REAL8 values;
END;

CombinedWorkItems := RECORD
  NumericField.wi;
  DATASET(CombinedFields) d;
END;

CombinedLabels := RECORD
  NumericField.wi;
  DATASET(Labels) d;
END;

ip := PROJECT(samples,TRANSFORM(CombinedFields,
                                SELF.wi := LEFT.wi,
                                SELF.id := LEFT.id,
                                SELF.label := PredLabels(wi=SELF.wi and id=SELF.id)[1].label,
                                SELF.values := [LEFT.value]));

ip2 := ROLLUP(SORT(ip,wi,id),TRANSFORM(CombinedFields,
                                       SELF.values := LEFT.values + RIGHT.values,
                                       SELF := LEFT), wi,id);

ip3 := ROLLUP(GROUP(ip2,wi), GROUP, TRANSFORM(CombinedWorkItems,
                                              SELF.wi := LEFT.wi,
                                              SELF.d := ROWS(LEFT)));

DATASET(ML_Core.Types.Silhouette_Result) sklearn_silhouette(DATASET(CombinedWorkItems) s) :=
EMBED(Python)
  from sklearn.metrics import silhouette_score as sil
  r = 0
  result = []
  for workItem in s:
    wi = workItem.wi
    points = []
    labels = []
    for p in workItem.d:
      c = ()
      for v in p.values:
        c = list(c)
        c.append(v)
        c = tuple(c)
      points.append(c)
      labels.append(p.label)
    result.append((wi,sil(points,labels)))
  return result
ENDEMBED;

sk_sil_score := sklearn_silhouette(ip3);

comparison := JOIN(ML_Sil_Score, sk_sil_score,
                   LEFT.wi = RIGHT.wi,
                   TRANSFORM({NumericField.wi, REAL8 ML_Core, REAL8 sklearn},
                             SELF.wi := LEFT.wi,
                             SELF.ML_Core := LEFT.score,
                             SELF.sklearn := RIGHT.score));

OUTPUT(comparison);
