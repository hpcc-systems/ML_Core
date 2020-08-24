/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;
IMPORT Preprocessing.Utils;

NumericField := MLC.Types.NumericField;

/**
 * Shuffles data and split into training and test data
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
EXPORT RandomSplit(DATASET(NumericField) dataToSplit, REAL4 trainSize = 0.0, REAL4 testSize = 0.0) := FUNCTION
  Result := $.Split(utils.shuffle(dataToSplit).ds,trainSize,testSize);  
  RETURN Result;
END;