/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;
IMPORT $.Files;

Encoder := ML_Core.Preprocessing.LabelEncoder;

/**
  * Allows to run performance test for LabelEncoder
  */
KeyLayout := RECORD
  SET OF STRING nom_0;
  SET OF STRING nom_1;
  SET OF STRING nom_2;
  SET OF STRING nom_3;
  SET OF STRING nom_4;
  SET OF STRING nom_5;
  SET OF STRING nom_6;
  SET OF STRING nom_7;
  SET OF STRING nom_8;
  SET OF STRING nom_9;
  SET OF STRING ord_1;
  SET OF STRING ord_2;
  SET OF STRING ord_3;
  SET OF STRING ord_4;
  SET OF STRING ord_5;
END;

testData := DATASET(Files.pathPrefix + 'structuredData', Files.RawDataLayout, THOR);
n := 30000;
testData1 := testData[1..n];
testData2 := testData[1..(2*n)];
testData3 := testData[1..(3*n)];
testData4 := testData[1..(4*n)];
testData5 := testData[1..(5*n)];
testData6 := testData[1..(6*n)];
testData7 := testData[1..(7*n)];
testData8 := testData[1..(8*n)];
testData9 := testData[1..(9*n)];
testData10 := testData[1..(10*n)];
partialKey := ROW({[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]}, KeyLayout);

//partialKey := ROW({[],[]}, KeyLayout);

key := Encoder.GetKey(testData1, partialKey);
encodedData := encoder.encode(testData1, key);
OUTPUT(encodedData,, Files.pathPrefix + 'EncodedData', THOR, COMPRESSED, OVERWRITE);
decodedData := encoder.decode(encodedData, key);
OUTPUT(decodedData,, Files.pathPrefix + 'DecodedData', THOR, COMPRESSED, OVERWRITE);