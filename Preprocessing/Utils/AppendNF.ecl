IMPORT $.^.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;

/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Appends a numeric field dataset to another
 *
 * @param ds1: DATASET(NumericField)
 *   The dataset to append to
 *
 * @param ds2: DATASET(NumericField)
 *   The dataset to be appended
 *
 * @return the merged dataset with ds2 following ds1
 */
EXPORT AppendNF (DATASET(NumericField) ds1, DATASET(NumericField) ds2) := FUNCTION
  
  ds1LastNumber := MAX(SET(ds1, number));

  NumericField updateNumber (NumericField L) := TRANSFORM
    SELF.number := L.number + ds1LastNumber;
    SELF := L;
  END;

  updatedDS2 := PROJECT(ds2, updateNumber(LEFT));
  Result := MERGE(ds1, updatedDS2, SORTED(wi, id, number));
  RETURN Result;
END;
