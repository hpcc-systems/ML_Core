IMPORT $ AS ML_Core;
IMPORT ML_Core.Types AS Types;
IMPORT ML_Core.Utils AS Utils;
IMPORT Std.System.ThorLib;
/**
  * Calculate various statistical aggregations of the fields in
  * a NumericField dataset.
  * @param d The dataset to be aggregated.
  **/
EXPORT FieldAggregates(DATASET(Types.NumericField) d) := MODULE
  // Simple statistics
  SingleField := RECORD
    d.wi;
    d.number;
    Types.t_fieldreal minval  :=MIN(GROUP,d.Value);
    Types.t_fieldreal maxval  :=MAX(GROUP,d.Value);
    Types.t_fieldreal sumval  :=SUM(GROUP,d.Value);
    Types.t_fieldreal countval:=COUNT(GROUP);
    Types.t_fieldreal mean    :=AVE(GROUP,d.Value);
    Types.t_fieldreal var     :=VARIANCE(GROUP,d.Value);
    Types.t_fieldreal sd      :=SQRT(VARIANCE(GROUP,d.Value));
  END;
  /**
    * Calculate basic statistics about each field.
    * <p>Calculates: min, max, sum, count, mean, variance, and
    * standard deviation for each field.
    * <p>There are no parameters.
    * <p>Example:
    * <pre>myAggs := FieldAggregates(myDS).simple;</pre>
    **/
  EXPORT Simple:=TABLE(d,SingleField, wi, Number,FEW);
  // Simple Ranked
  RankableField := RECORD
    d;
    UNSIGNED Pos := 0;
  END;
  Sorted_D := SORT(D,wi,Number,Value);
  T := TABLE(Sorted_D,RankableField);
  P := Utils.SequenceInField(T, Number, Pos, wi);
  /**
    * Calculate the rank (order) of each cell for each field.
    * <p>The returned data adds a 'Pos' field to each cell, indicating
    * its rank within it's field number.
    * <p> There are no parameters.
    * <p> Example:
    * <pre>myRankedDS := FieldAggregates(myDS).SimpleRanked;</pre>
    **/
  EXPORT SimpleRanked := P;
  // Medians
  dMedianPos:=TABLE(SimpleRanked,
    {wi; number;
     SET OF UNSIGNED pos:=IF(MAX(GROUP,pos)%2=0,
                            [(MAX(GROUP,pos))/2,(MAX(GROUP,pos))/2+1],
                            [(MAX(GROUP,pos)/2)+1]);},
     wi, number, FEW);
  dMedianValues:=JOIN(SimpleRanked,dMedianPos,
                      LEFT.wi=RIGHT.wi AND LEFT.number=RIGHT.number
                      AND LEFT.pos IN RIGHT.pos,
                      TRANSFORM({RECORDOF(SimpleRanked) AND NOT [id,pos];},
                                SELF:=LEFT;),
                      LOOKUP);
  /**
    * Calculate the median value of each field.
    * <p> There are no parameters.
    * @return DATASET({wi, number, median}), one record per work-item and field number.
    * <p>Example:
    * <pre>myFieldMedians := FieldAggregates(myDS).Medians;</pre>
    **/
  EXPORT Medians:=TABLE(dMedianValues,
         {wi, number;
          TYPEOF(dMedianValues.value) median:=IF(COUNT(GROUP)=1,
                                                  MIN(GROUP,value),
                                                  SUM(GROUP,value)/2);},
         wi, number,FEW);
  // Min median
  nextRec:= RECORD(RECORDOF(Medians))
    TYPEOF(SimpleRanked.value) nextval;
  END;
  // MinMedNext is used on KDTree, when median = minval nextval is used
  // instead median in order to avoid endless right-node propagation
  //NOTE: when RIGHT is not present MAX(RIGHT.value, LEFT.median) works
  // only for LEFT.median positive values, otherwise it returns 0
  // (0 is greater than a negative number)
  dNextVals:= JOIN(Medians, SimpleRanked,
                  LEFT.wi=RIGHT.wi AND LEFT.number = RIGHT.number
                  AND LEFT.median < RIGHT.value,
                  TRANSFORM(nextRec, SELF:= LEFT,
                            SELF.nextval:= MAX(RIGHT.value, LEFT.median)),
                  KEEP(1), LEFT OUTER);
  EXPORT MinMedNext:= JOIN(dNextVals, Simple,
                           LEFT.wi=RIGHT.wi
                           AND LEFT.number = RIGHT.number, LOOKUP);
  // Buckets
  {RECORDOF(SimpleRanked);Types.t_Discrete bucket;}
  tAssign(SimpleRanked L,Simple R,Types.t_Discrete n):=TRANSFORM
    SELF.bucket:=IF(L.value=R.maxval,
           n,
           (Types.t_Discrete)(n*((L.value-R.minval)/(R.maxval-R.minval)))+1);
    SELF:=L;
  END;
  /**
    * Bucketize the datapoints into N buckets for each field.
    * <p>Bucketization splits the range of the data into N equal size
    * range buckets.  The data will not normally be evenly split
    * among buckets unless it is uniformly distributed.  Contrast this
    * with N-tile, where the data is split nearly evenly.
    * @param n The number of buckets to use.
    * @return DATASET OF {wi, id, number, value, pos, bucket}, where
    *         pos is the rank within each field, and bucket is the
    *         bucket number. 
    **/
  EXPORT Buckets(Types.t_Discrete n)
        :=JOIN(SimpleRanked,Simple,
               LEFT.wi=RIGHT.wi AND LEFT.number=RIGHT.number,
               tAssign(LEFT,RIGHT,n),LOOKUP);
  /**
    * Return the ranges associated with each of N buckets
    * as computed by 'Buckets' above.
    * @param n The number of buckets.
    * @return DATASET OF {wi, number, bucket, Min, and Max}, one for
    *         each bucket for each field.
    **/
  EXPORT BucketRanges(Types.t_Discrete n)
        :=TABLE(Buckets(n),
                {wi, number;bucket;
                 Types.t_fieldreal Min:=MIN(GROUP,value);
                 Types.t_fieldreal Max:=MAX(GROUP,value);
                 UNSIGNED cnt:=COUNT(GROUP);},
                wi, number, bucket);
  // Modes
  MR := RECORD
    SimpleRanked.wi;
    SimpleRanked.Number;
    SimpleRanked.Value;
    Types.t_FieldReal Pos := AVE(GROUP,SimpleRanked.Pos);
    UNSIGNED valcount:=COUNT(GROUP);
  END;
  SHARED T := TABLE(SimpleRanked, MR, wi, Number, Value);
  dModeVals:=TABLE(T,{wi,number;UNSIGNED modeval:=MAX(GROUP,valcount);},
                  wi, number,FEW);
  /**
    * Calculate the mode (i.e. the most common value) for each field
    *
    * <p>There are no parameters.
    * @return DATASET OF {wi, number, mode, cnt}, one per field.
    *          'cnt' is the number of times the mode value occurred.
    **/
  EXPORT Modes:=JOIN(T,dModeVals,
                    LEFT.wi=RIGHT.wi AND LEFT.number=RIGHT.number
                    AND LEFT.valcount=RIGHT.modeval,
                    TRANSFORM({TYPEOF(T.wi) wi; TYPEOF(T.number) number;
                               TYPEOF(T.value) mode; UNSIGNED cnt},
                             SELF.cnt := LEFT.valcount;
                             SELF.mode:=LEFT.value;
                             SELF:=LEFT;),
                    LOOKUP);
  // Cardinality
  /**
    * Returns the cardinality of each field.  That is the number of different
    * values occurring in each field.
    * <p>There are no parameters.
    * @return DATASET OF {wi, number, cardinality}, one per field.
    **/
  EXPORT Cardinality:=TABLE(T,{wi, number;
                        UNSIGNED cardinality:=COUNT(GROUP);},wi, number);
  // Ranked
  SHARED AveRanked := RECORD
    d;
    Types.t_FieldReal Pos;
  END;
  AveRanked Into(D le,T ri) := TRANSFORM
    SELF.Pos := ri.pos;
    SELF := le;
  END;
  EXPORT RankedInput := JOIN(D,T,
                          LEFT.wi=RIGHT.wi AND LEFT.Number=RIGHT.Number
                          AND LEFT.Value = RIGHT.Value,
                          Into(LEFT,RIGHT));
  // N-Tile
  {RECORDOF(RankedInput);Types.t_Discrete ntile;}
  tNTile(RankedInput L,Simple R,Types.t_Discrete n):=TRANSFORM
    SELF.ntile:=IF(L.pos=R.countval,n,
                    (Types.t_Discrete)(n*((L.pos-1)/R.countval))+1);
    SELF:=L;
  END;
  /**
    * Calculate the N-tile of each datapoint within its field.
    * For example, if N is 100, we calculate percentiles.
    * @param n The number of groups into which to balance the data
    * @return DATASET OF {wi, id, number, value, pos, ntile}, where
    *         pos is the rank within each field.
    **/
  EXPORT NTiles(Types.t_Discrete n):=JOIN(RankedInput, Simple,
                                LEFT.wi=RIGHT.wi
                                AND LEFT.number=RIGHT.number,
                                tNTile(LEFT,RIGHT,n),LOOKUP);
  /**
    * Return the ranges associated with each of N-tiles
    * as computed by 'Ntiles' above.
    * @param n The number of N-tile groups.
    * @return DATASET OF {wi, number, bucket, Min, and Max}, one for
    *         each N-tile group for each field.
    **/
  EXPORT NTileRanges(Types.t_Discrete n):=TABLE(NTiles(n),
                      {wi;number;ntile;
                       Types.t_fieldreal Min:=MIN(GROUP,value);
                       Types.t_fieldreal Max:=MAX(GROUP,value);
                       UNSIGNED cnt:=COUNT(GROUP);},
                      wi, number, ntile);
  // N-Histogram
  {RECORDOF(d);Types.t_Discrete hbin;}
  tHistBin(RECORDOF(d) L,Simple R,Types.t_Discrete n):=TRANSFORM
    SELF.hbin := IF(L.value = R.maxval, n,
                    (Types.t_Discrete) n*(L.value - R.minval)/(R.maxval - R.minval)+1);
    SELF:=L;
  END;
  EXPORT HistBins(Types.t_Discrete n):=JOIN(d, Simple,
                                LEFT.wi=RIGHT.wi
                                AND LEFT.number=RIGHT.number,
                                tHistBin(LEFT,RIGHT,n),LOOKUP);
  EXPORT HistBinRanges(Types.t_Discrete n):=TABLE(HistBins(n),
                    {wi;number;hbin;
                     Types.t_fieldreal Min:=MIN(GROUP,value);
                     Types.t_fieldreal Max:=MAX(GROUP,value);
                     UNSIGNED cnt:=COUNT(GROUP);},
                    wi, number, hbin);
  // Pearson product-moment correlation matrix
  SHARED dChildRec := RECORD
    d.id;
    d.value;
    Types.t_FieldReal Pos;
  END;
  SHARED dDenormRec := RECORD
    d.wi;
    d.number;
    DATASET(dChildRec) d := DATASET([], dChildRec);
  END;
  dParent := PROJECT(Simple, dDenormRec);
  dDenormRec tDenorm(dParent L, AveRanked R) := TRANSFORM
    SELF.d := L.d + PROJECT(DATASET(R),dChildRec);
    SELF := L;
  END;
  SHARED dDenorm := DENORMALIZE(dParent, RankedInput,
                         LEFT.wi = RIGHT.wi
                         AND LEFT.number = RIGHT.number,
                         tDenorm(LEFT,RIGHT));
  SHARED combineRec := RECORD(dChildRec)
    Types.t_fieldreal value2;
  END;
  SHARED corrRec := RECORD
    d.wi;
    Types.t_Discrete number1;
    Types.t_Discrete number2;
    Types.t_fieldreal Correl;
  END;
  corrRec tPearson(dDenormRec L, dDenormRec R) := TRANSFORM
    SELF.number1 := L.number;
    SELF.number2 := R.number;
    LRd := JOIN(L.d,R.d,LEFT.id = RIGHT.id,
               TRANSFORM(combineRec,
                         SELF.value2 := RIGHT.value,
                         SELF := LEFT));
    SELF.Correl := CORRELATION(LRd, value, value2);
    SELF := L;
  END;
  EXPORT PearsonCorr := JOIN(dDenorm, dDenorm,
                  LEFT.wi=RIGHT.wi AND LEFT.number <= RIGHT.number,
                  tPearson(LEFT,RIGHT));
  // Spearman's rho correlation matrix
  corrRec tSpearman(dDenormRec L, dDenormRec R) := TRANSFORM
    SELF.number1 := L.number;
    SELF.number2 := R.number;
    LRd := JOIN(L.d,R.d,LEFT.id = RIGHT.id,
               TRANSFORM(combineRec,
                         SELF.value := LEFT.pos,
                         SELF.value2 := RIGHT.pos,
                         SELF := LEFT));
    SELF.Correl := CORRELATION(LRd, value, value2);
    SELF := L;
  END;
  EXPORT SpearmanCorr := JOIN(dDenorm, dDenorm,
                  LEFT.wi=RIGHT.wi AND LEFT.number <= RIGHT.number,
                  tSpearman(LEFT,RIGHT));
  // Kendall's tau-b correlation matrix
  KendallCompRec := RECORD
    UNSIGNED2 Concordant;
    UNSIGNED2 Discordant;
  END;
  KendallTiesRec := RECORD
    n_t := COUNT(GROUP) * (COUNT(GROUP) - 1) / 2;
  END;
  KendallCompRec KendallComp(combineRec L, combineRec R) := TRANSFORM
    SELF.Concordant := IF((L.value < R.value AND L.value2 < R.value2) OR
                          (L.value > R.value AND L.value2 > R.value2),
                          1, 0);
    SELF.Discordant := IF((L.value < R.value AND L.value2 > R.value2) OR
                          (L.value > R.value AND L.value2 < R.value2),
                          1, 0);
  END;
  REAL8 Kendall(DATASET(combineRec) LRd) := FUNCTION
    components := JOIN(LRd, LRd, LEFT.id <> RIGHT.id AND LEFT.id < RIGHT.id, KendallComp(LEFT,RIGHT), ALL);
    n_t_L := SUM(TABLE(LRd, KendallTiesRec, value ), n_t);
    n_t_R := SUM(TABLE(LRd, KendallTiesRec, value2), n_t);
    n_c := SUM(components, Concordant);
    n_d := SUM(components, Discordant);
    n := COUNT(components);
    tau := (n_c - n_d) / SQRT((n - n_t_L) * (n - n_t_R));
    return(tau);
  END;
  corrRec tKendall(dDenormRec L, dDenormRec R) := TRANSFORM
    SELF.number1 := L.number;
    SELF.number2 := R.number;
    LRd := JOIN(L.d,R.d,LEFT.id = RIGHT.id,
               TRANSFORM(combineRec,
                         SELF.value := LEFT.pos,
                         SELF.value2 := RIGHT.pos,
                         SELF := LEFT));
    SELF.Correl := Kendall(LRd);
    SELF := L;
  END;
  EXPORT KendallCorr := JOIN(dDenorm, dDenorm,
                  LEFT.wi=RIGHT.wi AND LEFT.number <= RIGHT.number,
                  tKendall(LEFT,RIGHT));
  // Generalized Spearman rho correlation matrix (each independent vs dependent)
  // See the R package 'Hmisc' by Frank Harrell (and the function 'biVar').
  corrRec tGenSpearman2(dDenormRec L, dDenormRec R) := TRANSFORM
    SELF.number1 := L.number;
    SELF.number2 := R.number;
    LRd := JOIN(L.d,R.d,LEFT.id = RIGHT.id,
               TRANSFORM(combineRec,
                         SELF.value := LEFT.pos,
                         SELF.value2 := RIGHT.pos,
                         SELF := LEFT));
    unique := COUNT(TABLE(LRd, {value2}, value2));
    XYSpearman := CORRELATION(LRd, value, value2);
    XSqYSpearman := CORRELATION(LRd, value, POWER(value2,2));
    XXSqSpearman := CORRELATION(LRd, value2, POWER(value2,2));
    SELF.Correl := IF(unique < 3,
      POWER(XYSpearman, 2),
      (POWER(XYSpearman,2) - 2 * XYSpearman * XSqYSpearman * XXSqSpearman + POWER(XSqYSpearman,2))
        / (1 - POWER(XXSqSpearman,2))
    );
    SELF := L;
  END;
  EXPORT GenSpearman2Corr(dep = 1) := JOIN(dDenorm, dDenorm,
                  LEFT.wi=RIGHT.wi AND LEFT.number = dep AND RIGHT.number <> dep,
                  tGenSpearman2(LEFT,RIGHT));
  // End Field Aggregates
END;
