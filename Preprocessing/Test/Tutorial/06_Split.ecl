/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;
IMPORT $.^.^.^ as ML_Core;
IMPORT $.^.^ as Prep;

cFeature := Prep.Types.OneHotEncoder.cFeatures;
Preprocessing := ML_Core.Preprocessing;
NumericField := ML_Core.Types.NumericField;

splitResult := Preprocessing.split(Files.MLData, 0.8);
trainData := splitResult.trainData;
testData := splitResult.testData;

xCatTrain := trainData(number = 10);
ytrain := PROJECT(trainData(number = 9), TRANSFORM(NumericField, SELF.number := 1, SELF := LEFT));
xCatTest := testData(number = 10);
ytest := PROJECT(testData(number = 9), TRANSFORM(NumericField, SELF.number := 1, SELF := LEFT));
xNumTrain := trainData(number < 9);
xNumTest := testData(number < 9);


OUTPUT(yTrain,,Files.yTrainPath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(yTest,,Files.yTestPath, THOR, COMPRESSED, OVERWRITE);


//scaling numerical features
scaler := Preprocessing.StandardScaler(xNumTrain);
xTrainScaled := scaler.scale(xNumTrain);
xTestScaled := scaler.scale(xNumTest);

//oneHotEncoding categorical features
encoderTrain := Preprocessing.OneHotEncoder(xCatTrain, DATASET([{1,10}], cFeature));
xTrainEncoded := encoderTrain.encode;
encoderTest := Preprocessing.OneHotEncoder(xCatTest, DATASET([{1,10}], cFeature));
xTestEncoded := encoderTest.encode;

//merging numeric and categorical features
cleanXTrain := Preprocessing.Utils.AppendNF(xTrainScaled, xTrainEncoded);
cleanXTest := Preprocessing.Utils.AppendNF(xTestScaled, xTestEncoded);
OUTPUT(cleanXTrain,,Files.cleanXTrainPath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(cleanXTest,,Files.cleanXTestPath, THOR, COMPRESSED, OVERWRITE);