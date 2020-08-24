IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

YStatsRec := PTypes.StratifiedSplit.YStatsRec;
comparisonResultRec := Utils.Types.comparisonResultRec;

CompareRowByRow(DATASET(YStatsRec) s1, DATASET(YStatsRec) s2) := FUNCTION
  comparisonResultRec compare(YStatsRec L, UNSIGNED cnt) := TRANSFORM
    value1 := s1[cnt].value;
    value2 := s2[cnt].value;
    cnt1 := s1[cnt].cnt;
    cnt2 := s2[cnt].cnt;

    SELF.val := IF(value1 = value2 AND cnt1 = cnt2, TRUE, FALSE);
  END;
  
  comparisonResult := PROJECT(s1, compare(LEFT, COUNTER));
  Result := IF(COUNT(comparisonResult(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN Result;
END;

EXPORT compareStats (DATASET(YStatsRec) s1, DATASET(YStatsRec) s2) := FUNCTION
  Result := IF(COUNT(s1) = COUNT(s2), compareRowByRow(s1, s2), FALSE);
  RETURN Result;
END;
