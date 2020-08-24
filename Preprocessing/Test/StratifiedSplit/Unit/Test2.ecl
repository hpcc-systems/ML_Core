/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;
IMPORT $.^.^.^.^ as MLC;
IMPORT Preprocessing.Utils as utl;
IMPORT * FROM $.Utils;
IMPORT $.TestData;

/**
 * Test case 2
 * Stratified split provided train size and default yId
 */
MLC.toField(TestData.ds, sampleData);

splitResult := Preprocessing.StratifiedSplit(sampleData, 0.5);

yStatsInDS := splitResult.yStatsInDS;
OUTPUT(bindStats(yStatsInDS, testData.expYStatsInDS), NAMED('yStatsInDS'));
assertMsgStatsDS := 'yStatsInDS are different from expected';
ASSERT(compareStats(yStatsInDS, testData.expYStatsInDS) = TRUE, assertMsgStatsDS);

yStatsInTrainDS := splitResult.yStatsInTrainDS;
OUTPUT(bindStats(yStatsInTrainDS, testData.expYStatsInTrainDS), NAMED('yStatsInTrainDS'));
assertMsgStatsTrain := 'yStatsInTrainDS are different from expected';
ASSERT(compareStats(yStatsInTrainDS, testData.expYStatsInTrainDS) = TRUE, assertMsgStatsTrain);

yStatsInTestDS := splitResult.yStatsInTestDS;
OUTPUT(bindStats(yStatsInTestDS, testData.expYStatsInTestDS), NAMED('yStatsInTestDS'));
assertMsgStatsTest := 'yStatsInTestDS are different from expected';
ASSERT(compareStats(yStatsInTestDS, testData.expYStatsInTestDS) = TRUE, assertMsgStatsTest);

trainData := splitResult.trainData;
OUTPUT(utl.bindNF(trainData, testData.expTrainData), NAMED('trainData'));
assertMsgTrainDS := 'Train data are different from expected';
ASSERT(utl.compareNF(trainData, testData.expTrainData) = TRUE, assertMsgTrainDS);

testData_ := splitResult.testData;
OUTPUT(utl.bindNF(testData_, testData.expTestData), NAMED('testData'));
assertMsgTestDS := 'Test data are different from expected';
ASSERT(utl.compareNF(testData_, testData.expTestData) = TRUE, assertMsgTestDS);