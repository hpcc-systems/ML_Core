/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;
Types := Preprocessing.Types;
NumericField := ML_Core.Types.NumericField;

/**
 * Split data into training and test data.
 *
 * @param dataToSplit: DATASET(Types.NumericField).
 *   <p> The data to split.
 *
 * @param trainSize: REAL4, DEFAULT = 0.0.
 *   <p> The training size. If 0.0, it will be set as count(dataToSplit) - testSize.
 *
 * @param testSize: REAL4, DEFAULT = 0.0.
 *   <p> The test size. If 0.0, it will be set as count(dataToSplit) - trainSize.
 *
 * @param shuffle: Boolean, DEFAULT = false.
 *   <p> if true, the data is shuffled before splitting.
 *
 * @return training and test data
 */
EXPORT Split(DATASET(NumericField) dataToSplit, 
             REAL4 trainSize = 0.0, 
             REAL4 testSize = 0.0, 
             BOOLEAN shuffle = FALSE) := FUNCTION  
  
  ids := DEDUP(DATASET(SET(dataToSplit, id), Types.idLayout));
  
  //Get the count of training and test sets
  dataCount := COUNT(ids);
  trainCount := ROUND(IF(trainSize = 0.0, dataCount * (1-testSize), dataCount * trainSize));
  testCount := ROUND(IF(testSize = 0.0, dataCount * (1-trainSize), dataCount * testSize));
  
  //get ids of training and test sets
  traininingIds := SET(ids, id)[1..trainCount];
  testIds := SET(ids, id)[(trainCount + 1) .. (trainCount + testCount)];
  
  //extract training and test data
  ds := IF(shuffle = TRUE, Preprocessing.Utils.Shuffle(dataToSplit), dataToSplit);
  trainData := ds(id IN traininingIds);
  testData := ds(id IN testIds);
  
  //fix ids ordering so it starts from 1
  finalTrainData := Preprocessing.Utils.ResetID(trainData);
  finalTestData := Preprocessing.Utils.ResetID(testData);

  ResultLayout := RECORD
    DATASET(NumericField) trainData;
    DATASET(NumericField) testData;
  END;

  splitResult := DATASET([{finalTrainData, finalTestData}], ResultLayout);

  //validate input before splitting
  validationMsg := $.Utils.ValidateSplitInput(dataToSplit, trainSize, testSize);
  Result := IF(validationMsg = 'valid', 
               splitResult, 
               ERROR(ResultLayout, validationMsg));
  
  RETURN Result[1];
END;
