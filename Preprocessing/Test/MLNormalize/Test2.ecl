/**
 * Testing MLNormalize with empty input
 */

/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT * FROM $.Utils;
IMPORT Preprocessing.Utils as utl;

emptyData := DATASET([], MLC.Types.NumericField);
emptyNorm := DATASET([], Preprocessing.PTypes.MLNormalize.NormsRec);

normalizedDataL1 := Preprocessing.MLNormalize(emptyData, 'l1');
OUTPUT(setNormsSideBySide(normalizedDataL1.norms, emptyNorm), NAMED('L1Norm'));
ASSERT(compareNorms(normalizedDataL1.norms, emptyNorm) = TRUE, 'L1 norm is different from expected');
OUTPUT(utl.bindNF(normalizedDataL1.val, emptyData), NAMED('L1NormalizedData'));
ASSERT(utl.compareNF(normalizedDataL1.val, emptyData) = TRUE, 'L1 normalized data is different from expected');

normalizedDataL2 := Preprocessing.MLNormalize(emptyData, 'l2');
OUTPUT(setNormsSideBySide(normalizedDataL2.norms, emptyNorm), NAMED('L2Norm'));
ASSERT(compareNorms(normalizedDataL2.norms, emptyNorm) = TRUE, 'L2 norm is different from expected');
OUTPUT(utl.bindNF(normalizedDataL2.val, emptyData), NAMED('L2NormalizedData'));
ASSERT(utl.compareNF(normalizedDataL2.val, emptyData) = TRUE, 'L2 normalized data is different from expected');

normalizedDataLInf := Preprocessing.MLNormalize(emptyData, 'inf');
OUTPUT(setNormsSideBySide(normalizedDataLInf.norms, emptyNorm), NAMED('LInfNorm'));
ASSERT(compareNorms(normalizedDataLInf.norms, emptyNorm) = TRUE, 'LInf norm is different from expected');
OUTPUT(utl.bindNF(normalizedDataLInf.val, emptyData), NAMED('LInfNormalizedData'));
ASSERT(utl.compareNF(normalizedDataLInf.val, emptyData) = TRUE, 'LInf normalized data is different from expected');