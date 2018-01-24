/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */
// This test exercises the CrossValidation module.
// Note that in order for this test to work, the LearningTrees module
// must be installed because we need some bundle to test against.
// This file may show up with an error if LearningTrees is not installed,
// but that does not affect the rest of the bundle.
IMPORT $.^ AS ML_Core;

/**
  * Use the Cover Type database of Rocky Mountain Forest plots.
  * Perform a Random Forest classification to determine the primary Cover Type
  * (i.e. tree species) for each plot of land.
  * Do not be confused by the fact that we are using Random Forests to predict
  * tree species in an actual forest :)
  * @see test/datasets/CovTypeDS.ecl
  */
IMPORT LearningTrees AS LT;
IMPORT LT.LT_Types;
IMPORT LT.test.datasets.CovTypeDS;
IMPORT ML_Core.Types;

numTrees := 20;
maxDepth := 255;
numFeatures := 0; // Zero is automatic choice
balanceClasses := FALSE;
nonSequentialIds := TRUE; // True to renumber ids, numbers and work-items to test
                            // support for non-sequentiality
numWIs := 2;     // The number of independent work-items to create
maxRecs := 5000; // Filter on the number of records to use.  Max is 5000.
numFolds := 10;
t_Discrete := Types.t_Discrete;
t_FieldReal := Types.t_FieldReal;
DiscreteField := Types.DiscreteField;
NumericField := Types.NumericField;
trainDat := CovTypeDS.trainRecs;
testDat := CovTypeDS.testRecs;
ctRec := CovTypeDS.covTypeRec;
nominalFields := CovTypeDS.nominalCols;
numCols := CovTypeDS.numCols;


ML_Core.ToField(trainDat, trainNF);
ML_Core.ToField(testDat, testNF);

// First test Classification Cross-Validation

X0 := PROJECT(trainNF(number != 52 AND id <= maxRecs), TRANSFORM(NumericField,
        SELF.number := IF(nonSequentialIds, 5*LEFT.number, LEFT.number),
        SELF.id := IF(nonSequentialIds, 5*LEFT.id, LEFT.id),
        SELF := LEFT));
Y0 := PROJECT(trainNF(number = 52 AND id <= maxRecs), TRANSFORM(DiscreteField,
        SELF.number := 1,
        SELF.id := IF(nonSequentialIds, 5*LEFT.id, LEFT.id),
        SELF := LEFT));
// Generate multiple work items
X := NORMALIZE(X0, numWIs, TRANSFORM(RECORDOF(LEFT),
          SELF.wi := IF(nonSequentialIds, 5*COUNTER, COUNTER),
          SELF := LEFT));
Y := NORMALIZE(Y0, numWIs, TRANSFORM(RECORDOF(LEFT),
          SELF.wi := IF(nonSequentialIds, 5*COUNTER, COUNTER),
          SELF := LEFT));

myLearner := LT.ClassificationForest(numTrees, numFeatures, maxDepth); 

rslt := ML_Core.CrossValidation.NFoldCV(myLearner, X, Y, numFolds);

modC := rslt.Model;
modStats := myLearner.GetModelStats(modC);

OUTPUT(modStats, NAMED('ModelStatistics'));
OUTPUT(rslt.ClassStats, NAMED('ClassStats'));
OUTPUT(rslt.Accuracy, NAMED('Accuracy'));
OUTPUT(rslt.AccuracyByClass, NAMED('AccuracyByClass'));
OUTPUT(rslt.ConfusionMatrix, NAMED('ConfusionMatrix'));

// Now test Regression

XR0 := PROJECT(trainNF(number != 1), TRANSFORM(NumericField,
        SELF.number := IF(nonSequentialIds, (5*LEFT.number -1), LEFT.number -1),
        SELF.id := IF(nonSequentialIds, 5*LEFT.id, LEFT.id),
        SELF := LEFT));
YR0 := PROJECT(trainNF(number = 1), TRANSFORM(NumericField,
        SELF.number := 1,
        SELF.id := IF(nonSequentialIds, 5*LEFT.id, LEFT.id),
        SELF := LEFT));
// Generate multiple work items
XR := NORMALIZE(XR0, numWIs, TRANSFORM(RECORDOF(LEFT),
          SELF.wi := IF(nonSequentialIds, 5*COUNTER, COUNTER),
          SELF := LEFT));
YR := NORMALIZE(YR0, numWIs, TRANSFORM(RECORDOF(LEFT),
          SELF.wi := IF(nonSequentialIds, 5*COUNTER, COUNTER),
          SELF := LEFT));

IMPORT Python;
SET OF UNSIGNED incrementSet(SET OF UNSIGNED s, INTEGER increment) := EMBED(Python)
  outSet = []
  for i in range(len(s)):
    outSet.append(s[i] + increment)
  return outSet
ENDEMBED;
// Fixup IDs of nominal fields to match
nomFields := incrementSet(nominalFields, -1);

myLearnerR := LT.RegressionForest(numTrees, numFeatures, maxDepth);

rsltR := ML_Core.CrossValidation.NFoldCV(myLearnerR, XR, YR, numFolds);
modR := rsltR.Model;

modStatsR := myLearnerR.GetModelStats(modR);

OUTPUT(modStatsR, NAMED('RegressionModelStatistics'));
OUTPUT(rsltR.Accuracy, NAMED('RegressionAccuracy'));
