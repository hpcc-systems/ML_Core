IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

comparisonResultRec := Utils.Types.comparisonResultRec;
normsRec := PTypes.MLNormalize.NormsRec;

compareRowByRow (DATASET(normsRec) n1, DATASET(normsRec) n2) := FUNCTION
  rowIDs := Utils.GetRowIDs(COUNT(n1));

  comparisonResultRec compare(utils.Types.idRec rowID) := TRANSFORM
    id := rowID.val;
    rowID1 := n1[id].id;
    rowID2 := n2[id].id;
    value1 := n1[id].value;
    value2 := n2[id].value;

    SELF.val := IF(rowID1 = rowID2 AND Utils.CompareReals(value1, value2), TRUE, FALSE);
  END;

  comparisonRowByRow := PROJECT(rowIDs, compare(LEFT));

  comparisonResult := IF(COUNT(comparisonRowByRow(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN comparisonResult;
END;

EXPORT compareNorms(DATASET(normsRec) n1, DATASET(normsRec) n2) := FUNCTION
  comparisonResult := IF(COUNT(n1) = COUNT(n2), compareRowByRow(n1, n2), FALSE);
  RETURN comparisonResult;
END;