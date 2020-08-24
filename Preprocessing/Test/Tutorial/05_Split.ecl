/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */
IMPORT $.Files;
IMPORT $.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;

splitResult := Preprocessing.split(Files.MLData, 0.8);
trainData := splitResult.trainData;
testData := splitResult.testData;

xAndyTrain := Preprocessing.Utils.ExtractFeatures(trainData, [9]);
xTrain := xAndyTrain.remainder;
yTrain := xAndyTrain.extracted;

xAndyTest := Preprocessing.Utils.ExtractFeatures(testData, [9]);
xTest := xAndyTest.remainder;
yTest := xAndyTest.extracted;

OUTPUT(xTrain,,Files.xTrainPath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(yTrain,,Files.yTrainPath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(xTest,,Files.xTestPath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(yTest,,Files.yTestPath, THOR, COMPRESSED, OVERWRITE);
