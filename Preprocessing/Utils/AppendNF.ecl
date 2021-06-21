IMPORT $.^.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;

/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Merge two NumericField datasets ds1 and ds2 by appending ds2 to ds1.
 *
 * For example, merge ds1 and ds2 as following:
 * ds1 := DATASET({[1, 1, 1, 0.5]}, NumericField);
 * ds2 := DATASET({[1, 2, 1, 2.0]}, NumericField);
 * The result after merging is as below:
 * mergedDs := DATASET({[1, 1, 1, 0.5],
 *                      [1, 2, 2, 2.0]}, NumericField);
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
