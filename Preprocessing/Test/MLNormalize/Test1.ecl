/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Testing MLNormalize with non empty input
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT $.TestData;
IMPORT * FROM $.Utils;
IMPORT Preprocessing.Utils as utl;

MLC.ToField(testData.sampleData, sampleDataNF);

normalizedDataL1 := Preprocessing.MLNormalize(sampleDataNF, 'l1');
OUTPUT(setNormsSideBySide(normalizedDataL1.norms, testData.sklearnL1Norm), NAMED('L1Norm'));
ASSERT(compareNorms(normalizedDataL1.norms, testData.sklearnL1Norm) = TRUE, 'L1 norm is different from expected');
OUTPUT(utl.bindNF(normalizedDataL1.val, testData.sklearnL1NormalizedData), NAMED('L1NormalizedData'));
ASSERT(utl.compareNF(normalizedDataL1.val, testData.sklearnL1NormalizedData) = TRUE, 'L1 normalized data is different from expected');

normalizedDataL2 := Preprocessing.MLNormalize(sampleDataNF, 'l2');
OUTPUT(setNormsSideBySide(normalizedDataL2.norms, testData.sklearnL2Norm), NAMED('L2Norm'));
ASSERT(compareNorms(normalizedDataL2.norms, testData.sklearnL2Norm) = TRUE, 'L2 norm is different from expected');
OUTPUT(utl.bindNF(normalizedDataL2.val, testData.sklearnL2NormalizedData), NAMED('L2NormalizedData'));
ASSERT(utl.compareNF(normalizedDataL2.val, testData.sklearnL2NormalizedData) = TRUE, 'L2 normalized data is different from expected');

normalizedDataLInf := Preprocessing.MLNormalize(sampleDataNF, 'inf');
OUTPUT(setNormsSideBySide(normalizedDataLInf.norms, testData.sklearnLInfNorm), NAMED('LInfNorm'));
ASSERT(compareNorms(normalizedDataLInf.norms, testData.sklearnLInfNorm) = TRUE, 'LInf norm is different from expected');
OUTPUT(utl.bindNF(normalizedDataLInf.val, testData.sklearnLInfNormalizedData), NAMED('LInfNormalizedData'));
ASSERT(utl.compareNF(normalizedDataLInf.val, testData.sklearnLInfNormalizedData) = TRUE, 'LInf normalized data is different from expected');