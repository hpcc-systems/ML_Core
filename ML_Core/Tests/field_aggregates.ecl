IMPORT $.^ AS ML_Core;
IMPORT ML_Core.Types;

// Generate test data
Types.NumericField make(UNSIGNED c, Types.t_Work_Item wi) := TRANSFORM
  SELF.wi := wi;
  SELF.id := ((c-1) DIV 3) + 1;
  SELF.number := ((c-1) % 3) + 1;
  SELF.value := MAP((c-1)%3 = 0   => (REAL8)(((c-1) DIV 10) + 1),
                    (c-1)%3 = 1   => RANDOM()%20,
                    ((RANDOM()-1)%1000)/1000);
END;
wi_1 := DATASET(60, make(COUNTER, 1), DISTRIBUTED);
wi_2 := DATASET(1000, make(COUNTER, 2), DISTRIBUTED);

single_wi := ML_Core.FieldAggregates(wi_1);
two_wi := ML_Core.FieldAggregates(wi_1+wi_2);

EXPORT field_aggregates := PARALLEL(
   OUTPUT(TOPN(wi_1+wi_2, 100, wi, number, id), ALL, NAMED('Input'))
  ,OUTPUT(single_wi.Simple, NAMED('Single_Simple'))
  ,OUTPUT(single_wi.SimpleRanked, NAMED('Single_SimpleRanked'))
  ,OUTPUT(single_wi.Medians, NAMED('Single_Medians'))
  ,OUTPUT(single_wi.MinMedNext, NAMED('Single_MinMedNext'))
  ,OUTPUT(single_wi.Buckets(10), NAMED('Single_10_buckets'))
  ,OUTPUT(single_wi.BucketRanges(10), NAMED('Single_10_ranges'))
  ,OUTPUT(single_wi.Modes, NAMED('Single_Modes'))
  ,OUTPUT(single_wi.Cardinality, NAMED('Single_Cardinality'))
  ,OUTPUT(single_wi.RankedInput, NAMED('Single_RankedInput'))
  ,OUTPUT(single_wi.NTiles(10), NAMED('Single_NTiles'))
  ,OUTPUT(single_wi.NTileRanges(10), NAMED('Single_NTRange'))
  ,OUTPUT(two_wi.Simple, NAMED('Two_Simple'))
  ,OUTPUT(CHOOSEN(two_wi.SimpleRanked, 200), ALL, NAMED('Two_200_Ranked'))
  ,OUTPUT(two_wi.Medians, NAMED('Two_Medians'))
);