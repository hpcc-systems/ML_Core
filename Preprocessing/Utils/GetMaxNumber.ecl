/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT ML_CORE.Types;

/**
 * Determines the maximum number
 */
EXPORT GetMaxNumber(DATASET(Types.NumericField) ds) := FUNCTION
  RETURN MAX(SET(ds, number));
END;