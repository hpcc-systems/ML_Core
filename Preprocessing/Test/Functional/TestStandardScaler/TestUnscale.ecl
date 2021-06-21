/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;

/**
  * Test UnScale
  */

scaler := Preprocessing.StandardScaler($.testData.sampleData);
result := scaler.unscale($.testData.scaledData);
result;
