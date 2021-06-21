/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

/**
  * Test Encode in LabelEncoder
  */
IMPORT $.^.^.^.^ as ML_Core;

Encoder := ML_Core.Preprocessing.LabelEncoder;
sampleData := $.TestDataAndTypes.sampleData;
sampleData2 := $.TestDataAndTypes.sampleData2;
key := $.TestDataAndTypes.key;

/**
  * Test encode
  */

result1 := encoder.encode(sampleData, key);
result1;
