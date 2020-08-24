/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * test case 5
 * scaler is constructed such that min >= max
 * GetKey() must throw error
 */

IMPORT $.^.^.^.^ as MLC;
IMPORT Preprocessing;
IMPORT $.TestData;

MLC.ToField(testData.ds, sampleData);
keyRec := Preprocessing.PTypes.StandardScaler.KeyRec;
scaler := Preprocessing.MinMaxScaler(sampleData, 200, 100);

//testing getKey()
key := scaler.getKey();
OUTPUT(key, NAMED('Key'));