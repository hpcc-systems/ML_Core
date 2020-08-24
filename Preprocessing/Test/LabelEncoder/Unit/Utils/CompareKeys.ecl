IMPORT Preprocessing.Test.LabelEncoder.Unit.TestData;

keyRec := TestData.KeyRec;

EXPORT compareKeys(DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  comparisonResult := IF(k1[1].f1 = k2[1].f1 AND k1[1].f3 = k2[1].f3 AND k1[1].f4 = k2[1].f4, TRUE, FALSE);
  RETURN comparisonResult;
END;