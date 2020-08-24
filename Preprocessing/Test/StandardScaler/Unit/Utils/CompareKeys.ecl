IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

comparisonResultRec := Utils.Types.comparisonResultRec;
keyRec := PTypes.StandardScaler.KeyRec;

compareRowByRow (DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  rowIDs := Utils.GetRowIDs(COUNT(k1));

  comparisonResultRec compare(utils.Types.idRec rowID) := TRANSFORM
    id := rowID.val;
    featureID1 := k1[id].featureID;
    featureID2 := k2[id].featureID;
    mean1 := k1[id].mean_;
    mean2 := k2[id].mean_;
    std1 := k1[id].std_;
    std2 := k2[id].std_;

    SELF.val := IF(featureID1 = featureID2 AND Utils.CompareReals(mean1, mean2) AND Utils.CompareReals(std1, std2), TRUE, FALSE);
  END;

  comparisonRowByRow := PROJECT(rowIDs, compare(LEFT));

  comparisonResult := IF(COUNT(comparisonRowByRow(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN comparisonResult;
END;

EXPORT compareKeys(DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  comparisonResult := IF(COUNT(k1) = COUNT(k2), compareRowByRow(k1, k2), FALSE);
  RETURN comparisonResult;
END;