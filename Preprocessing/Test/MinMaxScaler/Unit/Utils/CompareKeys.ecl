IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

comparisonResultRec := Utils.Types.comparisonResultRec;
keyRec := PTypes.MinMaxScaler.KeyRec;

compareRowByRow (DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  rowIDs := Utils.GetRowIDs(COUNT(k1));

  comparisonResultRec compare(utils.Types.idRec rowID) := TRANSFORM
    id := rowID.val;
    featureID1 := k1[id].featureID;
    featureID2 := k2[id].featureID;
    min1 := k1[id].min_;
    min2 := k2[id].min_;
    max1 := k1[id].max_;
    max2 := k2[id].max_;

    SELF.val := IF(featureID1 = featureID2 AND utils.CompareReals(min1, min2) AND utils.CompareReals(max1, max2), TRUE, FALSE);
  END;

  comparisonRowByRow := PROJECT(rowIDs, compare(LEFT));

  comparisonResult := IF(COUNT(comparisonRowByRow(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN comparisonResult;
END;

EXPORT compareKeys(DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  comparisonResult := IF(COUNT(k1) = COUNT(k2), compareRowByRow(k1, k2), FALSE);
  RETURN comparisonResult;
END;