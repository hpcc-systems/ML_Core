/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;
IMPORT Preprocessing;

//separating numeric and categorical features
xTrain := Preprocessing.ExtractFeatures(Files.xTrain, [9]);
xTrainNumeric := xTrain.remainder;
xTrainCategorical := xTrain.extracted;

xTest := Preprocessing.ExtractFeatures(Files.xTest, [9]);
xTestNumeric := xTest.remainder;
xTestCategorical := xTest.extracted;

//scaling numerical features
scaler := Preprocessing.StandardScaler(xTrainNumeric);
xTrainScaled := scaler.scale(xTrainNumeric);
xTestScaled := scaler.scale(xTestNumeric);

//oneHotEncoding categorical features
encoder := Preprocessing.OneHotEncoder(xTrainCategorical, [1]);
xTrainEncoded := encoder.encode(xTrainCategorical);
xTestEncoded := encoder.encode(xTestCategorical);

//merging numeric and categorical features
cleanXTrain := Preprocessing.AppendNF(xTrainScaled, xTrainEncoded);
cleanXTest := Preprocessing.AppendNF(xTestScaled, xTestEncoded);
OUTPUT(cleanXTrain,,Files.cleanXTrainPath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(cleanXTest,,Files.cleanXTestPath, THOR, COMPRESSED, OVERWRITE);