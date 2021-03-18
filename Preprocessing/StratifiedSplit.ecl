/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ as ML_Core;

Types := ML_Core.Preprocessing.Types;
Utils := ML_Core.Preprocessing.Utils;
NumericField := ML_Core.Types.NumericField;
valueLayout := Types.valueLayout;

//layout for keeping count of label values in dataset
YCountsLayout := RECORD
  REAL value;
  UNSIGNED cnt;
END;

/**
 * Determine, from full data, the count of each value of the field whose number id is yId.
 *
 * @param ds: DATASET(NumericField).
 *   <p> The dataset from which to extract the values' count.
 *
 * @param yId: UNSIGNED.
 *   <p> The id of the field.
 *
 * @return the values' count in full data: DATASET(YCountsLayout).
 */
GetYCountsInDS(DATASET(NumericField) ds, UNSIGNED yId) := FUNCTION
  yValueSET := SET(ds(number = yid), value);
  yValues := DEDUP(SORT(DATASET(yValueSET, valueLayout), value));

  YCountsLayout GetYCounts (valueLayout L) := TRANSFORM
    SELF.value := L.value;
    SELF.cnt := COUNT(ds(value = L.value AND number = yId));
  END;

  Result := PROJECT(yValues, GetYCounts(LEFT));
  RETURN Result;
END;

/**
 * Determine, from train data, the count of each value of the field whose number id is yId.
 *
 * @param yCountsInDS: DATASET(YCountsLayout).
 *   <p> The y Counts from full data.
 *
 * @param trainSize: REAL4.
 *   <p> The training size.
 *
 * @return the values' count in train data: DATASET(YCountsLayout).
 */
GetYCountsInTrainDS(DATASET(YCountsLayout) yCountsInDS, REAL4 trainSize) := FUNCTION
  YCountsLayout GetYCounts(YCountsLayout L) := TRANSFORM
    SELF.value := L.value;
    SELF.cnt := ROUND(L.cnt * trainSize);
  END;
  
  Result := PROJECT(yCountsInDS, GetYCounts(LEFT));
  RETURN Result;
END;

/**
 * Determine, from test data, the count of each value of the field whose number id is yId.
 *
 * @param yCountsInDS: DATASET(YCountsLayout).
 *   <p> The y Counts from full data.
 *
 * @param testSize: REAL4.
 *   <p> The test size.
 *
 * @return the values' count in test data: DATASET(YCountsLayout).
 */
GetYCountsInTestDS(DATASET(YCountsLayout) yCountsInDS, REAL4 testSize) := FUNCTION
  YCountsLayout GetYCounts(YCountsLayout L) := TRANSFORM
    SELF.value := L.value;
    SELF.cnt := ROUND(L.cnt * testSize);
  END;
  
  Result := PROJECT(yCountsInDS, GetYCounts(LEFT));
  RETURN Result;
END;

/**
 * Extracts train and test data based on label field (yid) and 
 * label field values' count in train and test data.
 *
 * @param ds: DATASET(NumericField).
 *   <p> The dataset from which to extract train and test sets.
 *
 * @param yid: UNSIGNED.
 *   <p> the label id.
 *
 * @param yCountsInTrainDS: DATASET(YCountsLayout).
 *   <p> Label field values' count in train data.
 *
 * @param yCountsInTestDS: DATASET(YCountsLayout).
 *   <p> Label field values' count in test data.
 *
 * @return training and test data.
 */
GetTrainAndTestData(DATASET(NumericField) ds, UNSIGNED yId, 
                    DATASET(YCountsLayout) yCountsInTrainDS,
                    DATASET(YCountsLayout) yCountsInTestDS) := FUNCTION

  ResultLayout := RECORD
    UNSIGNED cnt;
    DATASET(NumericField) trainData;
    DATASET(NumericField) testData;
  END;
  
  emptyNF := DATASET([], NumericField);
  initialLoopResult := DATASET([{1, emptyNF, emptyNF}], ResultLayout);
  maxNumber := MAX(SET(ds, number));

  Result := LOOP(initialLoopResult,
                     COUNT(yCountsInTrainDS),
                     PROJECT(ROWS(LEFT),
                            TRANSFORM(ResultLayout,
                              trainCount := yCountsInTrainDS[LEFT.cnt].cnt * maxNumber;
                              testCount := yCountsInTestDS[LEFT.cnt].cnt * maxNumber;
                              relevantIds := SET(ds(number = yid AND value = yCountsInTrainDS[LEFT.cnt].value), id);
                              relevantRows := ds(id IN relevantIds);
                              SELF.trainData := LEFT.trainData + relevantRows[1..trainCount];
                              SELF.testData := LEFT.testData + relevantRows[(trainCount + 1)..(trainCount + testCount)];
                              SELF.cnt := LEFT.cnt + 1)));
  
  RETURN Result;  
END;

/**
 * validate yId (must be between 1 and max field id).
 */
validateYID(DATASET(NumericField) ds, UNSIGNED yid) := FUNCTION
  maxNumber := MAX(SET(ds, number));
  Result := IF(yid >= 1 AND yid <= maxNumber, 'valid', 'yId valid range = [1, ' + maxNumber + ']');
  RETURN Result;
END;

/**
 * validate ds, trainSize, testSize and yId
 */
validateInput(DATASET(NumericField) ds, REAL4 trainSize, REAL4 testSize, UNSIGNED yId) := FUNCTION  
  splitValidationMsg := $.Utils.validateSplitInput(ds, trainSize, testSize);
  Result := IF(splitValidationMsg = 'valid', validateYID(ds, yId), splitValidationMsg);
  RETURN Result;
END;

/**
 * Allows to split data while maintaining the proportions of a feature.
 * 
 * @param ds: DATASET(NumericField).
 *   The data to split.
 *
 * @param trainSize: REAL4, Default = 0.0
 *   <p> The training size.
 *
 * @param testSize: REAL4, Default = 0.0
 *   <p> The test size.
 *
 * @param labelId: UNSIGNED, Default = 0.
 *   <p> The number of the field whose proportions has to be maintained.
 *
 * @return the training data, test data as DATASET(NumericField).
 */
EXPORT StratifiedSplit(DATASET(NumericField) ds, 
                       REAL4 trainSize = 0, REAL4 testSize = 0, UNSIGNED labelId = 0, 
                       BOOLEAN shuffle = FALSE) := FUNCTION

  yId := IF(labelId = 0, MAX(SET(ds, number)), labelId);
  finalTrainSize := IF(trainSize = 0, 1 - testSize, trainSize);
  finalTestSize := IF(testSize = 0, 1 - trainSize, testSize);  
  finalDS := IF(shuffle = TRUE, Utils.Shuffle(ds), ds);

  yCountsInDS := GetYCountsInDS(finalDS, yId);
  yCountsInTrainDS := GetYCountsInTrainDS(yCountsInDS, finalTrainSize);
  yCountsInTestDS := GetYCountsInTestDS(yCountsInDS, finalTestSize);  
  trainAndTestData := GetTrainAndTestData(finalDS, yId, yCountsInTrainDS, yCountsInTestDS);  

  tempTrainData := SORT(trainAndTestData.trainData, id);
  tempTestData := SORT(trainAndTestData.testData, id);

  finalTrainData := Utils.ResetID(tempTrainData);
  finalTestData := Utils.ResetID(tempTestData);
  
  Resultlayout := RECORD
    DATASET(NumericField) trainData;
    DATASET(NumericField) testData;
  END;

  SplitResult := DATASET([{finalTrainData, finalTestData}], Resultlayout);

  validationMsg := validateInput(ds, finalTrainSize, finalTestSize, yId);
  Result := IF(validationMsg = 'valid', 
               SplitResult, 
               ERROR(Resultlayout, validationMsg));

  RETURN Result[1];
END;
