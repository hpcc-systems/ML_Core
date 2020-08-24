/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT ML_CORE.Types;

NumericField := Types.NumericField;
Unsigned8Rec := RECORD
  UNSIGNED val;
END;

/**
 * Compare rows of two numeric field datasets
 */
compareRowByRow (DATASET(NumericField) d1, DATASET(NumericField) d2) := FUNCTION
  comparisonResultRec := $.Types.comparisonResultRec;
  rowIDs := $.GetRowIDs(COUNT(d1));

  comparisonResultRec compare(Unsigned8Rec rowID) := TRANSFORM
    id := rowID.val;
    wi1 := d1[id].wi;
    wi2 := d2[id].wi;
    id1 := d1[id].id;
    id2 := d2[id].id;
    number1 := d1[id].number;
    number2 := d2[id].number;
    value1 := d1[id].value;
    value2 := d2[id].value;

    SELF.val := IF(wi1 = wi2 AND id1 = id2 AND number1 = number2 AND $.CompareReals(value1, value2), TRUE, FALSE);
  END;

  comparisonRowByRow := PROJECT(rowIDs, compare(LEFT));

  comparisonResult := IF(COUNT(comparisonRowByRow(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN comparisonResult;
END;

/**
 * compare two numeric field datasets
 */
EXPORT CompareNF(DATASET(NumericField) d1, DATASET(NumericField) d2) := FUNCTION
  comparisonResult := IF(COUNT(d1) = COUNT(d2), compareRowByRow(d1, d2), FALSE);
  RETURN comparisonResult;
END;