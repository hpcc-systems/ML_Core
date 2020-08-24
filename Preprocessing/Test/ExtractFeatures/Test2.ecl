/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;
IMPORT $.TestData;
IMPORT Preprocessing.Utils as utl;

extractionResult := Preprocessing.ExtractFeatures(testData.sampleData, [2,4]);
remainder := extractionResult.remainder;
extracted := extractionResult.extracted;

OUTPUT(utl.bindNF(remainder, testData.expRemainder2), NAMED('Remainder1'));
errorMsgRemainder := 'Remainder1 is different from expected';
ASSERT(utl.compareNF(remainder, testData.expRemainder2) = TRUE, errorMsgRemainder);

OUTPUT(utl.bindNF(extracted, testData.expExtracted2), NAMED('Extracted1'));
errorMsgExtracted := 'Extracted1 is different from expected';
ASSERT(utl.compareNF(extracted, testData.expExtracted2) = TRUE, errorMsgExtracted);