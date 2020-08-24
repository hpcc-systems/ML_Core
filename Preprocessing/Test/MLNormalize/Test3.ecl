/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Testing MLNormalize with invalid norm
 * Error must be thrown
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT $.TestData;

MLC.ToField(testData.sampleData, sampleDataNF);
normalizedData := Preprocessing.MLNormalize(sampleDataNF, 'l12');
OUTPUT(normalizedData);