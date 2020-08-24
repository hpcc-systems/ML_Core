/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test split with invalid training and test size = 0.0
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT $.TestData;

MLC.toField(testData.sampleData, sampleDataNF);
splitResult := Preprocessing.Split(sampleDataNF);
OUTPUT(splitResult);