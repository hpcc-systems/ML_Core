/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Testing MLNormalize with default norm (l2)
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT $.TestData;
IMPORT $.Utils as Utl;
IMPORT Preprocessing.Utils;

MLC.ToField(testData.sampleData, sampleDataNF);
normalizedData := Preprocessing.MLNormalize(sampleDataNF);
OUTPUT(Utl.setNormsSideBySide(normalizedData.norms, testData.sklearnL2Norm), NAMED('Norm'));
ASSERT(Utl.compareNorms(normalizedData.norms, testData.sklearnL2Norm) = TRUE, 'Norm is different from expected');
OUTPUT(Utils.bindNF(normalizedData.val, testData.sklearnL2NormalizedData), NAMED('NormalizedData'));
ASSERT(Utils.compareNF(normalizedData.val, testData.sklearnL2NormalizedData) = TRUE, 'Normalized data is different from expected');