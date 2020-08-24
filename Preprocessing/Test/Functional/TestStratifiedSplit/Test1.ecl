/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;
IMPORT $.TestData;

Preprocessing := ML_Core.Preprocessing;
comparator := Preprocessing.Utils.DatasetComparator;

/**
 * Test case 1
 * Stratified split provided train size and yId
 */
ML_Core.toField(TestData.ds, sampleData);

splitResult := Preprocessing.StratifiedSplit(sampleData, 0.5,,4);

trainData := splitResult.trainData;
assertMsgTrainDS := 'Train data are different from expected';
ASSERT(comparator.compare(trainData, testData.expTrainData) = 0, assertMsgTrainDS);

testData_ := splitResult.testData;
assertMsgTestDS := 'Test data are different from expected';
ASSERT(comparator.compare(testData_, testData.expTestData) = 0, assertMsgTestDS);

