/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;
Preprocessing := ML_Core.Preprocessing;

/**
  * Test valid input
  */

scaler1 := Preprocessing.MinMaxScaler($.TestData.sampleData);
result1 := scaler1.unscale($.TestData.scaledData1);
result1;

/**
  * Test valid input
  */

scaler2 := Preprocessing.MinMaxScaler($.TestData.sampleData, -100, 100);
result2 := scaler2.unscale($.TestData.scaledData2);
result2;