/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT ML_CORE.Types;
NumericField := Types.NumericField;

/**
 * sets two numeric field datasets side by side for comparison
 */
EXPORT BindNF(DATASET(NumericField) d1, DATASET(NumericField) d2) := FUNCTION
  JoinedDataRec := RECORD
    DATASET(NumericField) ds1;
    DATASET(NumericField) ds2;
  END;
  
  joinedData := DATASET([{d1, d2}], JoinedDataRec)[1];
  RETURN joinedData;
END;