/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;
IMPORT $.TestData;
IMPORT Preprocessing.Utils as utl;

extractionResult := Preprocessing.ExtractFeatures(testData.sampleData, [1]);
remainder := extractionResult.remainder;
extracted := extractionResult.extracted;

OUTPUT(utl.bindNF(remainder, testData.expRemainder1), NAMED('Remainder1'));
errorMsgRemainder := 'Remainder1 is different from expected';
ASSERT(utl.compareNF(remainder, testData.expRemainder1) = TRUE, errorMsgRemainder);

OUTPUT(utl.bindNF(extracted, testData.expExtracted1), NAMED('Extracted1'));
errorMsgExtracted := 'Extracted1 is different from expected';
ASSERT(utl.compareNF(extracted, testData.expExtracted1) = TRUE, errorMsgExtracted);