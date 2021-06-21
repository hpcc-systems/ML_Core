/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;

/**
  * Test Scale
  */
scaler := Preprocessing.StandardScaler($.testData.sampleData);
result := scaler.scale($.testData.sampleData);
result;