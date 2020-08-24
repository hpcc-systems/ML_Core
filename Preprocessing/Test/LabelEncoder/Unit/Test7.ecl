/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test LabelEncoder Decode empty data
 * Must throw error
 */

IMPORT $.^.^.^.LabelEncoder as encoder;
IMPORT $.TestData;
IMPORT * FROM $.Utils;

featureList := DATASET([{[], [], ['low', 'med', 'high']}],  testData.KeyRec);
key := encoder.GetKey(testData.ds, featureList);

emptyData := DATASET([], testData.EncodedLayout);
encodedData := encoder.decode(emptyData, key);
OUTPUT(encodedData);