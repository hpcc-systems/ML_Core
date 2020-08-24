/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test LabelEncoder with data which has invalid categories
 */

IMPORT $.^.^.^.LabelEncoder as encoder;
IMPORT $.TestData;
IMPORT * FROM $.Utils;

featureList := DATASET([{[], [], ['low', 'med', 'high']}],  testData.KeyRec);
key := encoder.GetKey(testData.ds, featureList);
OUTPUT(bindKeys(key, testData.expKey), NAMED('Key'));
ASSERT(compareKeys(key, testData.expKey) = TRUE, 'Key is different from expected');

encodedData := encoder.encode(testData.ds2, testData.expKey);
OUTPUT(bindData(encodedData, testData.expEncodedData2), NAMED('EncodedData'));
ASSERT(compareData(encodedData, testData.expEncodedData2) = TRUE, 'encodedData is different from expected');

decodedData := encoder.decode(testData.expEncodedData2, testData.expKey);
OUTPUT(bindData(decodedData, testData.expDecodedData2), NAMED('DecodedData'));
ASSERT(compareData(decodedData, testData.expDecodedData2) = TRUE, 'DecodedData is different from expected');
