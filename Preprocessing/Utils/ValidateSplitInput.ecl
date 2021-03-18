/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;

/**
 * validates input for split function.
 * <p> input is valid if data is not empty, train and test sizes are not both zero, 
 * sizes are within [0.0, 1.0) with one of them being different from 0
 * and their sum does not exceed 1.0.
 *
 * @param dataToSplit: DATASET(Types.NumericField).
 *   <p> The data to split.
 *
 * @param trainSize: REAL4.
 *   <p> The training size.
 *
 * @param testSize: REAL4.
 *   <p> The test size.
 *
 * @return 'Data is empty' if dataToSplit is empty, 
 *   'Train size and test sizes are both 0.0' if the sizes are equal to zero, 
 *   'Invalid size! valid range = [0.0, 1.0)' if one of the sizes is out of range
 *   and 'Sizes are too large! trainSize + testSize > 1.0' if the sum of sizes exceeds 1.0.
 */
EXPORT validateSplitInput(DATASET(NumericField) dataToSplit, 
                          REAL4 trainSize, REAL4 testSize) := FUNCTION

  isValidSize(REAL4 size) := size >= 0.0 AND size < 1.0;

  Result := IF(COUNT(dataToSplit) = 0, 'Data is empty',
               IF(trainSize = 0.0 AND testSize = 0.0, 
                  'Train size and test sizes are both 0.0',
                   IF(~isValidSize(trainSize) OR ~isValidSize(testSize), 
                      'Invalid size! valid range = [0.0, 1.0)',
                       IF((trainSize + testSize) > 1.0, 
                          'Sizes are too large! trainSize + testSize > 1.0', 
                          'valid'))));
  RETURN Result;
END;