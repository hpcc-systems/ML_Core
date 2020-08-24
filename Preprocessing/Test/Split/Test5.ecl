/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test split with invalid train size (value > 1 or value <= 0)
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT $.TestData;

MLC.toField(testData.sampleData, sampleDataNF);
splitResult := Preprocessing.Split(sampleDataNF, 2);
OUTPUT(splitResult);