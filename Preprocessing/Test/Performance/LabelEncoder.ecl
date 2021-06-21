/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^ as Prep;

layout := RECORD
  UNSIGNED4 id;
  STRING c1;
  STRING c2;
  STRING c3;
  STRING c4;
  STRING c5;
  STRING c6;
END;
baseData := DATASET([{1, '1', '2', '3', '4', '5', '6'}], layout);
n := 5000000;

Layout transNorm(Layout l, INTEGER c) := TRANSFORM
  SELF.id := c;
  SELF.c1 :=  (STRING) (RANDOM() % 5);
  SELF.c2 :=  (STRING) (RANDOM() % 10);
  SELF.c3 :=  (STRING) (RANDOM() % 30);
  SELF.c4 :=  (STRING) (RANDOM() % 50);
  SELF.c5 :=  (STRING) (RANDOM() % 100);
  SELF.c6 :=  (STRING) (RANDOM() % 1000);
END;

 KeyLayout := RECORD
    SET OF STRING c1 := [];
    SET OF STRING c2 := [];
    SET OF STRING c3 := [];
    SET OF STRING c4 := [];
  END;

testData := NORMALIZE(baseData, n, transNorm(LEFT, COUNTER) );
keys := Prep.LabelEncoder.GetKey(testData, ROW({[]}, KeyLayout));
keys;
result := Prep.LabelEncoder.encode(testdata, keys);
OUTPUT(result);