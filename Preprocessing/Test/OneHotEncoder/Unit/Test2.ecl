/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Test oneHotEncoder with data which has some non existing categories
 */

IMPORT $.^.^.^.^ as MLC;
IMPORT $.TestData;
IMPORT MLC.Preprocessing.Utils as utl;

//convert to numeric field
MLC.ToField(testData.ds, sampleData);
encoder := MLC.Preprocessing.OneHotEncoder(sampleData, [1,3]);

ML_CORE.ToField(testData.ds2, sampleData2);

encodedData := encoder.encode(sampleData2);
OUTPUT(utl.bindNF(encodedData, testData.expEncodedData2), NAMED('EncodedData'));
ASSERT(utl.compareNF(encodedData, testData.expEncodedData2) = TRUE, 'encodedData is different from expected');

decodedData := encoder.decode(testData.expEncodedData2);
OUTPUT(utl.bindNF(decodedData, testData.expDecodedData2), NAMED('DecodedData'));
ASSERT(utl.compareNF(decodedData, testData.expDecodedData2) = TRUE, 'DecodedData is different from expected');
