/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test LabelEncoder Decode with empty key
 * Must throw error
 */

IMPORT $.^.^.^.LabelEncoder as encoder;
IMPORT $.TestData;
IMPORT * FROM $.Utils;

emptyKey := DATASET([], testData.KeyRec);
encodedData := encoder.decode(testData.expEncodedData1, emptykey);
OUTPUT(encodedData);