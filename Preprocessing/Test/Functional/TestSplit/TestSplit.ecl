/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;
IMPORT $.TestData;

Preprocessing := ML_Core.Preprocessing;

/**
  * Test with valid train size = 0.5.
  */

splitResult1 := Preprocessing.Split(testData.sampleData, 0.5);
splitResult1.trainData;
/**
  * Test with valid test size = 0.5.
  */

splitResult2 := Preprocessing.Split(testData.sampleData,, 0.5);
splitResult2.trainData;

/**
  * Test with valid train and test size.
  */

splitResult3 := Preprocessing.Split(testData.sampleData,0.5 , 0.5);
splitResult3.trainData;