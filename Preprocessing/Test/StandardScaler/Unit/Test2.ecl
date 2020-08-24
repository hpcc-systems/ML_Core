/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * test case 2
 * scaler is constructed with a key
 * The constructured scaler is then used to scale/unscale a sample data and an empty dataset
 */

IMPORT $.^.^.^.^ as MLC;
IMPORT * FROM $.Utils;
IMPORT Preprocessing.Utils as utl;
IMPORT Preprocessing;
IMPORT $.TestData;

keyRec := Preprocessing.PTypes.StandardScaler.KeyRec;
NumericField := MLC.Types.NumericField;

MLC.ToField(TestData.ds, sampleData);
emptyData := DATASET([], NumericField);
baseKey := testData.sklearnKey;
scaler := Preprocessing.StandardScaler(key := baseKey);

//testing getKey()
key := scaler.getKey();
OUTPUT(setKeysSideBySide(key, testData.sklearnKey), NAMED('Keys'));
ASSERT(compareKeys(key, testData.sklearnKey) = TRUE, 'key is different from expected');

//scaling and unscaling sampleData
scaledData := scaler.scale(sampleData);
OUTPUT(utl.bindNF(scaledData, testData.sklearnScaledData), NAMED('scaledData'));
ASSERT(utl.compareNF(scaledData, testData.sklearnScaledData) = TRUE, 'scaledData is different from expected');

unscaledData := scaler.unscale(testData.sklearnScaledData);
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