/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * test case 3
 * scaler is constructed with default parameters
 * The constructed scaler is then used to scale/unscale a sample data and an empty dataset
 */

IMPORT Preprocessing;

scaler := Preprocessing.StandardScaler();
key := scaler.getKey();
OUTPUT(key, NAMED('Key'));