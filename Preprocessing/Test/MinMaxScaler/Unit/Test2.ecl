/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * test case 2
 * scaler is constructed with non empty data and min and max are correctly set
 */

IMPORT $.^.^.^.^ as MLC;
IMPORT * FROM $.Utils;
IMPORT Preprocessing;
IMPORT Preprocessing.Utils as utl;
IMPORT $.TestData;

keyRec := Preprocessing.PTypes.MinMaxScaler.KeyRec;
NumericField := MLC.Types.NumericField;

MLC.ToField(TestData.ds, sampleData);
emptyData := DATASET([], NumericField);

scaler := Preprocessing.MinMaxScaler(sampleData, -100, 100);

//testing getKey()
key := scaler.getKey();
OUTPUT(SetKeysSideBySide(key, testData.sklearnKey), NAMED('Keys'));
ASSERT(compareKeys(key, testData.sklearnKey) = TRUE, 'key is different from expected');

//scaling and unscaling sampleData
scaledData := scaler.scale(sampleData);
OUTPUT(utl.bindNF(scaledData, testData.sklearnScaledData2), NAMED('scaledData'));
ASSERT(utl.compareNF(scaledData, testData.sklearnScaledData2) = TRUE, 'scaledData is different from expected');

unscaledData := scaler.unscale(testData.sklearnScaledData2);
eUnscaledData := sampleData;
OUTPUT(utl.bindNF(unscaledData, eUnscaledData), NAMED('unscaledData'));
ASSERT(utl.compareNF(unscaledData, eUnscaledData) = TRUE, 'unscaledData is different from expected');

//scaling and unscaling emptyData
scaledDataE := scaler.scale(emptyData);
sklearnScaledDataE := DATASET([], NumericField);
OUTPUT(utl.bindNF(scaledDataE, sklearnScaledDataE), NAMED('scaledDataE'));
ASSERT(utl.compareNF(scaledDataE, sklearnScaledDataE) = TRUE, 'scaledDataE is different from expected');

unscaledDataE := scaler.unscale(sklearnScaledDataE);
sklearnUncaledDataE := emptyData;
OUTPUT(utl.bindNF(unscaledDataE, sklearnUncaledDataE), NAMED('unscaledDataE'));
ASSERT(utl.compareNF(unscaledDataE, sklearnUncaledDataE) = TRUE, 'unscaledDataE is different from expected');