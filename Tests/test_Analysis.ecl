/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */
IMPORT $.^ AS ML_Core;

IMPORT ML_Core.Analysis;
IMPORT ML_Core.Types;

DiscreteField := Types.DiscreteField;
NumericField := Types.NumericField;

num_samples := 100;
num_classes := 5; // Number of class labels -- should be a factor of num_samples
num_variables := 2; // Number of classification variables (i.e. for multi-variate) --
                   // should be a factor of num_samples
num_wis := 3;  // Number of work-items -- should be a factor of num_samples

DiscreteField make_discrete(UNSIGNED c) := TRANSFORM
  SELF.wi := (c-1) DIV (num_samples * num_variables) + 1;
  SELF.number := (c-1) % num_variables + 1;
  SELF.id := c;
  SELF.value := ((c-1) DIV num_variables) % num_classes + 1;
END;

// Generate "actual" data for classification
class_actual := DATASET(num_samples * num_wis * num_variables, make_discrete(COUNTER));

OUTPUT(class_actual, ALL, NAMED('class_actual'));

class_pred := PROJECT(class_actual, TRANSFORM(DiscreteField,
                      SELF.value := IF((COUNTER-1) DIV num_variables % 4 = 0,
                                      IF(LEFT.value = num_classes, 1, LEFT.value + 1),
                                      LEFT.value); // Modify every fourth value by incrementing
                                                   // circularly.
                      SELF := LEFT));
OUTPUT(class_pred, ALL, NAMED('class_pred'));
// Distribute actual and pred by wi, number, and id
class_actualD := DISTRIBUTE(class_actual, HASH32(wi, number, id));
class_predD := DISTRIBUTE(class_pred, HASH32(wi, number, id));

class_stats := Analysis.Classification.ClassStats(class_actualD);

OUTPUT(class_stats, ALL, NAMED('class_stats'));

class_accuracy := Analysis.Classification.Accuracy(class_predD, class_actualD);

OUTPUT(class_accuracy, ALL, NAMED('class_accuracy'));

accuracy_by_class := Analysis.Classification.AccuracyByClass(class_predD, class_actualD);

OUTPUT(accuracy_by_class, ALL, NAMED('accuracy_by_class'));

confusion_matrix := Analysis.Classification.ConfusionMatrix(class_predD, class_actualD);

OUTPUT(confusion_matrix, ALL, NAMED('confusion_matrix'));

// Now test Regression Analysis
maxU4 := POWER(2, 32) - 1;
NumericField make_numeric(UNSIGNED c) := TRANSFORM
  SELF.wi := (c-1) DIV (num_samples * num_variables) + 1;
  SELF.number := (c-1) % num_variables + 1;
  SELF.id := c;
  SELF.value := RANDOM() / maxU4 - .5;
END;

noiseLevel := .5;
noise := RANDOM() / maxU4 * noiseLevel - (noiseLevel/2);

// Generate "actual" data for classification
regr_actual := DATASET(num_samples * num_wis * num_variables, make_numeric(COUNTER));

OUTPUT(regr_actual, ALL, NAMED('regr_actual'));

regr_pred := PROJECT(regr_actual, TRANSFORM(NumericField,
//                      SELF.value := IF((LEFT.id-1)%2 = 0, LEFT.value + noiseLevel,
//                                                          LEFT.value - noiseLevel),
                      SELF.value := LEFT.value + noise,
                      SELF := LEFT));
OUTPUT(regr_pred, ALL, NAMED('regr_pred'));
// Distribute actual and pred by wi, number, and id
regr_actualD := DISTRIBUTE(regr_actual, HASH32(wi, number, id));
regr_predD := DISTRIBUTE(regr_pred, HASH32(wi, number, id));

regr_accuracy := Analysis.Regression.Accuracy(regr_predD, regr_actualD);

OUTPUT(regr_accuracy, NAMED('regr_accuracy'));
