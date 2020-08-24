/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test split with trainSize + testSize > 1
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT $.TestData;

MLC.toField(testData.sampleData, sampleDataNF);
splitResult := Preprocessing.Split(sampleDataNF, 0.7, 0.8);
OUTPUT(splitResult);