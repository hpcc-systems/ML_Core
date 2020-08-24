/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test LabelEncoder Getkey with empty data
 * Must throw error
 */

IMPORT $.^.^.^.LabelEncoder as encoder;
IMPORT $.TestData;
IMPORT * FROM $.Utils;

featureList := DATASET([{[], [], ['low', 'med', 'high']}],  testData.KeyRec);
emptyData := DATASET([], testData.Layout);
key := encoder.GetKey(emptyData, featureList);
OUTPUT(key);