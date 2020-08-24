/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * test case 4 
 * scaler is constructed with default parameters
 * GetKey() must throw error
 */

IMPORT Preprocessing;

keyRec := Preprocessing.PTypes.StandardScaler.KeyRec;
scaler := Preprocessing.MinMaxScaler();

//testing getKey()
key := scaler.getKey();
OUTPUT(key, NAMED('Key'));