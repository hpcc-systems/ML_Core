/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;
IMPORT $.^.^.^ as ML_Core;
IMPORT LinearRegression AS LR;

model := LR.OLS(Files.cleanXTrain, Files.yTrain);
prediction := model.Predict(Files.cleanXTest);

ResultLayout := RECORD
  UNSIGNED id;
  REAL predicted;
  REAL actual;
END;

NumericField := ML_Core.Types.NumericField;
ResultLayout XF (NumericField L, NumericField R) := TRANSFORM
  SELF.id := L.id;
  SELF.predicted := L.value;
  SELF.actual := R.value;
END;

result := JOIN(prediction, Files.yTest,
               LEFT.id = RIGHT.id,
               XF(LEFT, RIGHT));

OUTPUT(Result,,Files.PredictionsPath, THOR, COMPRESSED, OVERWRITE);