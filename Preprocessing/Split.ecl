/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;
IMPORT Preprocessing.Utils;

NumericField := MLC.Types.NumericField;

//Record structure for split result
splitResultRec := RECORD
  DATASET(NumericField) trainData;
  DATASET(NumericField) testData;
END;

/**
 * Splits data provided that train and test sizes are valid
 */
SplitWithValidInput(DATASET(NumericField) dataToSplit, REAL4 trainSize, REAL4 testSize) := FUNCTION
  ids := SET($.Utils.GetIdsFromNF(dataToSplit), val);
  dataCount := COUNT(ids);
  trainCount := ROUND(IF(trainSize = 0.0, dataCount * (1-testSize), dataCount * trainSize));
  testCount := ROUND(IF(testSize = 0.0, dataCount * (1-trainSize), dataCount * testSize));
  
  traininingIds := ids[1..trainCount];
  testIds := ids[(trainCount + 1) .. (trainCount + testCount)];

  trainData := dataToSplit(id IN traininingIds);
  testData := dataToSplit(id IN testIds);

  finalTrainData := Utils.ResetID(trainData);
  finalTestData := Utils.ResetID(testData);

  Result := DATASET([{finalTrainData, finalTestData}], splitResultRec);
  RETURN Result;
END;

/**
 * determines if a given size is valid
 * A size is valid if in the range [0, 1)
 */
isValidSize(REAL4 size) := FUNCTION
  validity := IF(size >= 0.0 AND size < 1.0, TRUE, FALSE);
  RETURN validity;
END;

/**
 * Split data into training and test data
 *
 * @param dataToSplit: DATASET(Types.NumericField)
 *   The data to split
 *
 * @param trainSize: REAL4, DEFAULT = 0.0
 *   the training size. If 0.0, it will be set as count(dataToSplit) - testSize
 *
 * @param testSize: REAL4, DEFAULT = 0.0
 *   the test size. If 0.0, it will be set as count(dataToSplit) - trainSize
 *
 * @return training and test data
 */
EXPORT Split(DATASET(NumericField) dataToSplit, REAL4 trainSize = 0.0, REAL4 testSize = 0.0) := FUNCTION
  validationMsg := $.Utils.ValidateSplitInput(dataToSplit, trainSize, testSize);
  Result := IF(validationMsg = 'valid', 
               SplitWithValidInput(dataToSplit, trainSize, testSize), 
               ERROR(splitResultRec, validationMsg));
  
  RETURN Result[1];
END;
