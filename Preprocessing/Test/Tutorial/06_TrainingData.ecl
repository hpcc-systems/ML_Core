/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;
IMPORT $.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;

//separating numeric and categorical features
xTrain := Preprocessing.Utils.ExtractFeatures(Files.xTrain, [9]);
xTrainNumeric := xTrain.remainder;
xTrainCategorical := xTrain.extracted;

xTest := Preprocessing.Utils.ExtractFeatures(Files.xTest, [9]);
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
cleanXTrain := Preprocessing.Utils.AppendNF(xTrainScaled, xTrainEncoded);
cleanXTest := Preprocessing.Utils.AppendNF(xTestScaled, xTestEncoded);
OUTPUT(cleanXTrain,,Files.cleanXTrainPath, THOR, COMPRESSED, OVERWRITE);
OUTPUT(cleanXTest,,Files.cleanXTestPath, THOR, COMPRESSED, OVERWRITE);