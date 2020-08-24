/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT ML_CORE.Types;

/**
 * Extracts the unique ids from a numericField dataset
 *
 * @param ds: DATASET(Types.NumericField
 *   the dataset from which to extract the ids
 *
 * @return the dataset's ids
 */
EXPORT GetIdsFromNF(DATASET(Types.NumericField) ds) := FUNCTION
  idSET := SET(ds, id);
  uniqueIds := DEDUP(DATASET(idSET, $.Types.idRec));
  RETURN uniqueIds;
END;