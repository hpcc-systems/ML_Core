/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;
IMPORT $.TestData;

Preprocessing := ML_Core.Preprocessing;


result1 := Preprocessing.Normalizer(testData.sampleData, 'l1');
result2 := Preprocessing.Normalizer(testData.sampleData, 'l2');
result3 := Preprocessing.Normalizer(testData.sampleData, 'inf');

result1;
result2;
result3;
