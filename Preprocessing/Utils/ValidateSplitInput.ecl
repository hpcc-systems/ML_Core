/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT ML_CORE.Types;

/**
 * validates input for split function
 */
EXPORT validateSplitInput(DATASET(Types.NumericField) ds, REAL4 trainSize, REAL4 testSize) := FUNCTION
  isValidSize(REAL4 size) := size >= 0.0 AND size < 1.0;
  Result := IF(COUNT(ds) = 0, 'Data is empty',
              IF(trainSize = 0.0 AND testSize = 0.0, 'Train size and test size are both 0.0',
                IF(~isValidSize(trainSize) OR ~isValidSize(testSize), 'Invalid size! valid range = (0.0, 1.0)',
                  IF((trainSize + testSize) > 1.0, 'Sizes are too large! trainSize + testSize > 1.0', 'valid'))));
  RETURN Result;
END;