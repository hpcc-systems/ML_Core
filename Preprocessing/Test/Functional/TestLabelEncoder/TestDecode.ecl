/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

/**
  * Test Decode in LabelEncoder
  */
IMPORT $.^.^.^.^ as ML_Core;

Encoder := ML_Core.Preprocessing.LabelEncoder;
encodedData2 := $.TestDataAndTypes.encodedData2;
key := $.TestDataAndTypes.key;

/**
  * Test decode
  */

result2 := encoder.decode(encodedData2, key);
result2;