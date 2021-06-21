/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;
IMPORT $.TestData;

Preprocessing := ML_Core.Preprocessing;

/**
 * Stratified split provided train size and yId
 */
ML_Core.toField(TestData.ds, sampleData);
splitResult := Preprocessing.StratifiedSplit(sampleData, 0.5,,4);
trainData := splitResult.trainData;
testData_ := splitResult.testData;
trainData;
testData_;
