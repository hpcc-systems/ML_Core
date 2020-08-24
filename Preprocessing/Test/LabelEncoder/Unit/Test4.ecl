/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test LabelEncoder Getkey with empty featureList
 * Must throw error
 */

IMPORT $.^.^.^.LabelEncoder as encoder;
IMPORT $.TestData;
IMPORT * FROM $.Utils;

featureList := DATASET([],  testData.KeyRec);
key := encoder.GetKey(testData.ds, featureList);
OUTPUT(key);