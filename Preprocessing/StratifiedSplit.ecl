/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;
IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

NumericField := MLC.Types.NumericField;
YStatsRec := PTypes.StratifiedSplit.YStatsRec;
valueRec := utils.Types.valueRec;

//final record structure
ResultRec := RECORD
  DATASET(NumericField) trainData;
  DATASET(NumericField) testData;
  DATASET(PTypes.StratifiedSplit.YStatsRec) yStatsInDS;
  DATASET(PTypes.StratifiedSplit.YStatsRec) yStatsInTrainDS;
  DATASET(PTypes.StratifiedSplit.YStatsRec) yStatsInTestDS;
END;

/**
 * Extract all y values from data
 */
GetYValues(DATASET(NumericField) ds, UNSIGNED yId) := FUNCTION
  yValueSET := SET(ds(number = yid), value);
  yValueDS:= SORT(DATASET(yValueSET, valueRec), val);
  Result := DEDUP(yValueDS, val);
  RETURN Result;
END;

/**
 * Determines y stats in full data
 */
GetYStatsInDS(DATASET(NumericField) ds, UNSIGNED yId) := FUNCTION
  yValues := GetYValues(ds, yId);
  YStatsRec GetYStats (valueRec L) := TRANSFORM
    SELF.value := L.val;
    SELF.cnt := COUNT(ds(value = L.val AND number = yId));
  END;

  Result := PROJECT(yValues, GetYStats(LEFT));
  RETURN Result;
END;

/**
 * Determines y stats in train data
 */
GetYStatsInTrainDS(DATASET(YStatsRec) yStatsInDS, REAL4 trainSize) := FUNCTION
  YStatsRec GetYStats(YStatsRec L) := TRANSFORM
    SELF.value := L.value;
    SELF.cnt := ROUND(L.cnt * trainSize);
  END;
  
  Result := PROJECT(yStatsInDS, GetYStats(LEFT));
  RETURN Result;
END;

/**
 * Determines y stats in test data
 */
GetYStatsInTestDS(DATASET(YStatsRec) yStatsInDS, REAL4 testSize) := FUNCTION
  YStatsRec GetYStats(YStatsRec L) := TRANSFORM
    SELF.value := L.value;
    SELF.cnt := ROUND(L.cnt * testSize);
  END;
  
  Result := PROJECT(yStatsInDS, GetYStats(LEFT));
  RETURN Result;
END;

/**
 * Determines train and test data based on yId, y stats in train and test data
 */
GetTrainAndTestData(DATASET(NumericField) ds, UNSIGNED yId, DATASET(YStatsRec) yStatsInTrainDS,
                    DATASET(YStatsRec) yStatsInTestDS) := FUNCTION

  ResultRec := RECORD
    UNSIGNED cnt;
    DATASET(NumericField) trainData;
    DATASET(NumericField) testData;
  END;

  initialLoopResult := DATASET([{1, DATASET([], NumericField), DATASET([], NumericField)}], ResultRec);
  maxNumber := MAX(SET(ds, number));

  Result := LOOP(initialLoopResult,
                     COUNT(yStatsInTrainDS),
                     PROJECT(ROWS(LEFT),
                            TRANSFORM(ResultRec,
                              trainCount := yStatsInTrainDS[LEFT.cnt].cnt * maxNumber;
                              testCount := yStatsInTestDS[LEFT.cnt].cnt * maxNumber;
                              relevantIds := SET(ds(number = yid AND value = yStatsInTrainDS[LEFT.cnt].value), id);
                              relevantRows := ds(id IN relevantIds);
                              SELF.trainData := LEFT.trainData + relevantRows[1..trainCount];
                              SELF.testData := LEFT.testData + relevantRows[(trainCount + 1)..(trainCount + testCount)];
                              SELF.cnt := LEFT.cnt + 1)));
  
  RETURN Result;  
END;

/**
 * validates yId
 */
validateYID(DATASET(NumericField) ds, UNSIGNED yid) := FUNCTION
  maxNumber := $.Utils.GetMaxNumber(ds);
  Result := IF(yid >= 1 AND yid <= maxNumber, 'valid', 'yId valid range = [1, ' + maxNumber + ']');
  RETURN Result;
END;

/**
 * validates ds, trainSize, testSize and yId
 */
validateInput(DATASET(NumericField) ds, REAL4 trainSize, REAL4 testSize, UNSIGNED yId) := FUNCTION  
  splitValidationMsg := $.Utils.validateSplitInput(ds, trainSize, testSize);
  Result := IF(splitValidationMsg = 'valid', validateYID(ds, yId), splitValidationMsg);
  RETURN Result;
END;

/**
 * Splits if input is valid 
 */
SplitWithValidInput(DATASET(NumericField) ds, REAL4 trainSize, REAL4 testSize, UNSIGNED yId) := FUNCTION
  yStatsInDS := GetYStatsInDS(ds, yId);
  yStatsInTrainDS := GetYStatsInTrainDS(yStatsInDS, trainSize);
  yStatsInTestDS := GetYStatsInTestDS(yStatsInDS, testSize);  
  trainAndTestData := GetTrainAndTestData(ds, yId, yStatsInTrainDS, yStatsInTestDS);  

  tempTrainData := SORT(trainAndTestData.trainData, id);
  tempTestData := SORT(trainAndTestData.testData, id);

  finalTrainData := Utils.ResetID(tempTrainData);
  finalTestData := Utils.ResetID(tempTestData);

  Result := DATASET([{finalTrainData, finalTestData, yStatsInDS, yStatsInTrainDS, yStatsInTestDS}], ResultRec);
  RETURN Result;
END;

/**
 * Allows to split data while maintaining the proportions of a feature
 * 
 * @param ds: DATASET(NumericField)
 *   The data to split
 *
 * @param trainSize: REAL4, Default = 0.0
 *   The training size
 *
 * @param testSize: REAL4, Default = 0.0
 *   The test size
 *
 * @param yId: UNIGNED, Default = 0
 *   The number of the field whose proportions has to be maintained
 *
 * @return the training data, test data 
 *   and the count of the target field values in the full data, train data and test data
 */
EXPORT StratifiedSplit(DATASET(NumericField) ds, 
                       REAL4 trainSize = 0, REAL4 testSize = 0, UNSIGNED yId = 0) := FUNCTION

  yId_ := IF(yId = 0, MAX(SET(ds, number)), yId);
  trainSize_ := IF(trainSize = 0, 1 - testSize, trainSize);
  testSize_ := IF(testSize = 0, 1 - trainSize, testSize);

  validationMsg := validateInput(ds, trainSize_, testSize_, yId_);
  Result := IF(validationMsg = 'valid', 
               splitWithValidInput(ds, trainSize_, testSize_, yId_), 
               ERROR(ResultRec, validationMsg));

  RETURN Result[1];
END;
