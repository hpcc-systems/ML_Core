IMPORT $ AS ML_Core;
IMPORT ML_Core.Types AS Types;
IMPORT ML_Core.Utils AS Utils;
IMPORT Std.System.ThorLib;

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
  EXPORT Simple:=TABLE(d,SingleField, wi, Number,FEW);
  // Simple Ranked
  RankableField := RECORD
    d;
    UNSIGNED Pos := 0;
  END;
  Sorted_D := SORT(D,wi,Number,Value);
  T := TABLE(Sorted_D,RankableField);
  P := Utils.SequenceInField(T, Number, Pos, wi);
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
  EXPORT Buckets(Types.t_Discrete n)
        :=JOIN(SimpleRanked,Simple,
               LEFT.wi=RIGHT.wi AND LEFT.number=RIGHT.number,
               tAssign(LEFT,RIGHT,n),LOOKUP);
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
  EXPORT Cardinality:=TABLE(T,{wi, number;
                        UNSIGNED cardinality:=COUNT(GROUP);},wi, number);
  // Ranked
  AveRanked := RECORD
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
  EXPORT NTiles(Types.t_Discrete n):=JOIN(RankedInput, Simple,
                                LEFT.wi=RIGHT.wi
                                AND LEFT.number=RIGHT.number,
                                tNTile(LEFT,RIGHT,n),LOOKUP);
  EXPORT NTileRanges(Types.t_Discrete n):=TABLE(NTiles(n),
                      {wi;number;ntile;
                       Types.t_fieldreal Min:=MIN(GROUP,value);
                       Types.t_fieldreal Max:=MAX(GROUP,value);
                       UNSIGNED cnt:=COUNT(GROUP);},
                      wi, number, ntile);
  // End Field Aggregates
END;
