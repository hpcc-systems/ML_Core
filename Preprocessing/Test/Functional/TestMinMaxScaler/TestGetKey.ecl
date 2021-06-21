/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */
IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;


/**
  * Test compute key
  */
scaler1 := Preprocessing.MinMaxScaler($.TestData.sampleData);
result1 := scaler1.getKey();
result1;

/**
  * Test reusing key
  */
scaler2 := Preprocessing.MinMaxScaler(key := $.TestData.key1);
result2 := scaler2.getKey();
result2;
/**
  * Test changing min and max val
  */
scaler3 := Preprocessing.MinMaxScaler($.TestData.sampleData, -100, 100);
result3 := scaler3.getKey();
result3;