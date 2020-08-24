/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Test oneHotEncoder letting all default parameters
 * Should throw error: 'base data is empty'
 */

IMPORT Preprocessing;

encoder := Preprocessing.OneHotEncoder();
key := encoder.GetKey();
OUTPUT(key);