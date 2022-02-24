/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;
NumericField := ML_Core.Types.NumericField;

sample1 := $.testData.sample1;
sample2 := $.testData.sample2;
key := $.testData.key;


/**
  * Test encode
  */
encoder1 := Preprocessing.OneHotEncoder(sample1, key);
result1 := encoder1.encode;
result1;

/**
  * Test with unknown categories.
  */
encoder2 := Preprocessing.OneHotEncoder(sample2, key);
result2 := encoder2.encode;
result2;


/**
  * Test encoding empty data
  */

emptyNF := DATASET([], NumericField);
encoder3 := Preprocessing.OneHotEncoder(sample2, key);
result3 := encoder3.encode;
result3;


/**
  * Test decode
  */
result4 := encoder3.decode(result3);
result4;