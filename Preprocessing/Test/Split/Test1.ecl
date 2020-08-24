/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test split with valid training size 0.5
 */

IMPORT $.^.^.^ as MLC;
IMPORT MLC.Preprocessing;
IMPORT $.TestData;
IMPORT MLC.Preprocessing.Utils;

MLC.toField(testData.sampleData, sampleDataNF);
splitResult := Preprocessing.Split(sampleDataNF, 0.5);

OUTPUT(utils.bindNF(splitResult.trainData, testData.expTrainData), NAMED('TrainData'));
ASSERT(utils.compareNF(splitResult.trainData, testData.expTrainData) = TRUE, 'train data is different from expected');

OUTPUT(utils.bindNF(splitResult.testData, testData.expTestData), NAMED('TestData'));
ASSERT(utils.compareNF(splitResult.testData, testData.expTestData) = TRUE, 'test data is different from expected');