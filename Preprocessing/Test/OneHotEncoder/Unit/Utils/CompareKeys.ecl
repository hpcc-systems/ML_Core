IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

comparisonResultRec := Utils.Types.comparisonResultRec;
keyRec := PTypes.OneHotEncoder.KeyRec;
Unsigned8Rec := RECORD
  UNSIGNED val;
END;

compareRowByRow (DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  rowIDs := Utils.GetRowIDs(COUNT(k1));

  comparisonResultRec compare(Unsigned8Rec rowID) := TRANSFORM
    id := rowID.val;
    number1 := k1[id].number;
    number2 := k2[id].number;
    numInEncData1 := k1[id].startNumInEncData;
    numInEncData2 := k2[id].startNumInEncData;
    categories1 := k1[id].categories;
    categories2 := k2[id].categories;

    SELF.val := number1 = number2 AND numInEncData1 = numInEncData2 AND categories1 = categories2;
  END;

  comparisonRowByRow := PROJECT(rowIDs, compare(LEFT));

  comparisonResult := IF(COUNT(comparisonRowByRow(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN comparisonResult;
END;

EXPORT compareKeys(DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  comparisonResult := IF(COUNT(k1) = COUNT(k2), compareRowByRow(k1, k2), FALSE);
  RETURN comparisonResult;
END;