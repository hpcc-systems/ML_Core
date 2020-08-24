/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test LabelEncoder Encode with empty key
 * Must throw error
 */

IMPORT $.^.^.^.LabelEncoder as encoder;
IMPORT $.TestData;
IMPORT * FROM $.Utils;

emptyKey := DATASET([], testData.KeyRec);
encodedData := encoder.encode(testData.ds, emptykey);
OUTPUT(encodedData);