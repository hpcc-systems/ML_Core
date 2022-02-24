/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^ as Prep;
IMPORT $.^.^.^ as MLC;

layout := RECORD
  UNSIGNED4 id;
  REAL x1;
  REAL x2;
  REAL x3;
  REAL x4;
  REAL x5;
  REAL x6;
  REAL x7;
  REAL x8;
  REAL x9;
  REAL x10;
  REAL x11;
  REAL x12;
END;
baseData := DATASET([{1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}], layout );
n := 50000000;

Layout transNorm(Layout l, INTEGER c) := TRANSFORM
  SELF.x1  := 0.1 * random() % 10000 - 0.01 * L.x1  * random() % 100 ;
  SELF.x2  := 0.1 * random() % 10000 - 0.01 * L.x2  * random() % 100 ;
  SELF.x3  := 0.1 * random() % 10000 - 0.01 * L.x3  * random() % 100 ;
  SELF.x4  := 0.1 * random() % 10000 - 0.01 * L.x4  * random() % 100 ;
  SELF.x5  := 0.1 * random() % 10000 - 0.01 * L.x5  * random() % 100 ;
  SELF.x6  := 0.1 * random() % 10000 - 0.01 * L.x6  * random() % 100 ;
  SELF.x7  := 0.1 * random() % 10000 - 0.01 * L.x7  * random() % 100 ;
  SELF.x8  := 0.1 * random() % 10000 - 0.01 * L.x8  * random() % 100 ;
  SELF.x9  := 0.1 * random() % 10000 - 0.01 * L.x9  * random() % 100 ;
  SELF.x10 := 0.1 * random() % 10000 - 0.01 * L.x10 * random() % 100 ;
  SELF.x11 := 0.1 * random() % 10000 - 0.01 * L.x11 * random() % 100 ;
  SELF.x12 := 0.1 * random() % 10000 - 0.01 * L.x12 * random() % 100 ;
  SELF.id := c;
END;

testData := NORMALIZE(baseData, n, transNorm(LEFT, COUNTER) );
MLC.ToField(testdata,  NFTestData);
scaler := Prep.StandardScaler(NFtestData);
result := scaler.scale(NFtestData);
OUTPUT(result);