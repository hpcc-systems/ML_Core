/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test split with valid training and test size
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT $.TestData;
IMPORT Preprocessing.Utils as utl;

MLC.toField(testData.sampleData, sampleDataNF);
splitResult := Preprocessing.Split(sampleDataNF, 0.5, 0.5);

OUTPUT(utl.bindNF(splitResult.trainData, testData.expTrainData), NAMED('TrainData'));
ASSERT(utl.compareNF(splitResult.trainData, testData.expTrainData) = TRUE, 'train data is different from expected');

OUTPUT(utl.bindNF(splitResult.testData, testData.expTestData), NAMED('TestData'));
ASSERT(utl.compareNF(splitResult.testData, testData.expTestData) = TRUE, 'test data is different from expected');