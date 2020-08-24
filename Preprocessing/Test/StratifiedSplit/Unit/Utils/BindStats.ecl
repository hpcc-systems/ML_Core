IMPORT Preprocessing.Ptypes;
YStatsRec := PTypes.StratifiedSplit.YStatsRec;

EXPORT BindStats(DATASET(YStatsRec) s1, DATASET(YStatsRec) s2) := FUNCTION
  ResultRec := RECORD
    DATASET(YStatsRec) empiricalStats;
    DATASET(YStatsRec) expectedStats;
  END;
  
  Result := DATASET([{s1, s2}], ResultRec)[1];
  RETURN Result;
END;
