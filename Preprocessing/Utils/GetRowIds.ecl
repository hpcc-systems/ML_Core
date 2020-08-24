/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Builds a dataset made of sequential numbers from 1 to numOfRows.
 */
EXPORT GetRowIds (UNSIGNED numOfRows) := FUNCTION
  Unsigned8Rec := RECORD
    UNSIGNED val;
  END;

  rowIds := DATASET(numOfRows,
                    TRANSFORM(Unsigned8Rec,
                              SELF.val := COUNTER),
                              LOCAL);
  
  RETURN rowIds;
END;