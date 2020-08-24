/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Test LabelEncoder GetKey with typo in featureList record structure
 * Must throw error
 */

IMPORT $.^.^.^.LabelEncoder as encoder;
IMPORT $.TestData;

invalidKeyRec := RECORD
  SET OF STRING f1;
  SET OF STRING f3;
  SET OF STRING f5;
END;

featureList := DATASET([{[],[],['low', 'med', 'high']}],  invalidKeyRec);
key := encoder.GetKey(testData.ds, featureList);
OUTPUT(key);