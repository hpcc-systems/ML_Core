/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT ML_Core.Types;
IMPORT Preprocessing.Utils.Types as utlTypes;

numberRec := utlTypes.numberRec;

/**
 * Gets the feature Indexes from a numeric field dataset
 */
EXPORT GetFeatureIds(DATASET(Types.NumericField) ds) := FUNCTION
  numbers := SET(ds (id = 1), number);
  featureIDs := DATASET(numbers, numberRec);
  RETURN featureIDs;
END;