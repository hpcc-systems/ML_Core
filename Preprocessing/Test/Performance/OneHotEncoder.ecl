/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^ as Prep;
IMPORT $.^.^.^ as MLC;

cFeature := Prep.Types.OneHotEncoder.cFeatures;


layout := RECORD
  UNSIGNED4 id;
  UNSIGNED4 x1;
  UNSIGNED4 x2;
  UNSIGNED4 x3;
  UNSIGNED4 x4;
  UNSIGNED4 x5;
  UNSIGNED4 x6;
END;
baseData := DATASET([{1, 1, 2, 3, 4, 5, 6}], layout );
n := 5000000;

Layout transNorm(Layout l, UNSIGNED4 c) := TRANSFORM
  SELF.id := c;
  SELF.x1  := (RANDOM() % 5);;
  SELF.x2  := (RANDOM() % 10);
  SELF.x3  := (RANDOM() % 30);
  SELF.x4  := (RANDOM() % 50);
  SELF.x5  := (RANDOM() % 100);
  SELF.x6  := (RANDOM() % 1000);
END;

testData := NORMALIZE(baseData, n, transNorm(LEFT, COUNTER) );
MLC.ToField(testdata,  NFTestData);
encoder := Prep.OneHotEncoder(NFtestData, DATASET([{1, 1}, {1, 2}], cFeature));
result := encoder.encode;
OUTPUT(SORT(result, wi, id, number));