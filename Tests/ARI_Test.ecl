/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */
IMPORT $.^ AS ML_Core;
IMPORT Python;

// Generate test data

Labels := ML_Core.Types.ClusterLabels;

num_wis := 10;         // Number of work-items
num_samples := 200;    // Number of samples per work item
num_labels := 4;       // Number of clusters (unique labels)

Labels GenerateSample(UNSIGNED x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples) + 1;
  SELF.id := x;
  SELF.label := RANDOM() % num_labels;
END;

truth := DATASET(num_wis * num_samples, GenerateSample(COUNTER));
pred := DATASET(num_wis * num_samples, GenerateSample(COUNTER));

//Find ARI

ARI := ML_Core.Analysis.Clustering.ARI(pred, truth);

// Compare with Scikit Learn

REAL8 sklearn_ari(SET OF INTEGER x, SET OF INTEGER y) := EMBED(Python)
  from sklearn.metrics.cluster import adjusted_rand_score as ari
  return ari(x,y)
ENDEMBED;

comb := JOIN(truth, pred, LEFT.wi=RIGHT.wi and LEFT.id=RIGHT.id,
             TRANSFORM({RECORDOF(truth), INTEGER label2},
                       SELF.label2 := RIGHT.label,
                       SELF := LEFT));
                       
Comparison := ROLLUP(GROUP(SORT(comb,wi),wi),GROUP,
                      TRANSFORM({INTEGER wi, REAL8 ML_Core_ARI, REAL8 sklearn_ARI},
                                SELF.wi := LEFT.wi,
                                SELF.ML_Core_ARI := ARI(wi=LEFT.wi)[1].value,
                                SELF.sklearn_ARI := sklearn_ari(SET(ROWS(LEFT),label),
                                                                SET(ROWS(LEFT),label2))));

EXPORT ARI_Test := OUTPUT(Comparison);
