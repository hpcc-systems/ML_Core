/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Test oneHotEncoder with feature list having an invalid value
 * Invalid value must be ignored
 */

IMPORT $.^.^.^.^ as MLC;
IMPORT Preprocessing;
IMPORT $.TestData;
IMPORT * FROM $.Utils;
IMPORT Preprocessing.Utils as utl;

//convert to numeric field
MLC.ToField(testData.ds, sampleData);
encoder := Preprocessing.OneHotEncoder(sampleData, [1,3,4]);

key := encoder.GetKey();
OUTPUT(bindKeys(key, testData.expKey), NAMED('Key'));
ASSERT(compareKeys(key, testData.expKey) = TRUE, 'Key is different from expected');

encodedData := encoder.encode(sampleData);
OUTPUT(utl.bindNF(encodedData, testData.expEncodedData1), NAMED('EncodedData'));
ASSERT(utl.compareNF(encodedData, testData.expEncodedData1) = TRUE, 'encodedData is different from expected');

decodedData := encoder.decode(testData.expEncodedData1);
OUTPUT(utl.bindNF(decodedData, testData.expDecodedData1), NAMED('DecodedData'));
ASSERT(utl.compareNF(decodedData, testData.expDecodedData1) = TRUE, 'DecodedData is different from expected');
