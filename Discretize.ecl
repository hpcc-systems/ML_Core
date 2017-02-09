IMPORT $ AS ML_Core;
IMPORT ML_Core.Types;
/*
  This module exists to turn a dataset of numberfields into a dataset
  of DiscreteFields.  This is not quite as trivial as it seems as there
  are a number of different ways to make the underlying data discrete;
  and even within one method there may be different parameters.
  Further - it is quite probable that different methods are going to be
  desired for each field.
*/

EXPORT Discretize := MODULE
  /*
    These types are used to construct an 'instruction stream' to allow a dataset to be discretized according to a set of
    instructions which are in (meta)data
  */
  EXPORT c_Method := ENUM(Rounding,Bucketing,Tiling);
  EXPORT r_Method := RECORD
    SET OF Types.t_FieldNumber fields;
    c_Method                   method;
    INTEGER                    iParam1 := 0;
    REAL8                      rParam1 := 0;
    REAL8                      rParam2 := 0;
  END;

  /*
    Round the values passed in to create a discrete element
    Scale is applied (by multiplication) first and can be used to
    bring the data into a desired range (rParam1), Delta is applied
    (by addition) second and can be used to re-base a range
    OR to cause truncation or roundup as required (rParam2)
  */
  // Instruction for later
  EXPORT i_ByRounding(SET OF Types.t_FieldNumber f,
                      REAL Scale=1.0,REAL Delta=0.0)
  := DATASET([{f,c_Method.Rounding,0,Scale,Delta}],r_Method);
  // Actually do the work
  EXPORT ByRounding(DATASET(Types.NumericField) d,REAL Scale=1.0,
                    REAL Delta=0.0)
  := PROJECT(d,TRANSFORM(Types.DiscreteField,
                          SELF.Value := ROUND(LEFT.Value*Scale+Delta),
                          SELF := LEFT));

  /*
     Buckets allocates a continuous variable into one of N buckets
     based upon an equal division of the RANGE of the variable.
     The buckets will NOT have an even number of elements in unless
     the underlying distribution of the variable is uniform.
  */
  // Instruction for later
  EXPORT i_ByBucketing(SET OF Types.t_FieldNumber f,
                       Types.t_Discrete N=ML_Core.Config.Discrete)
    := DATASET([{f,c_Method.Bucketing,N,0,0}],r_Method);
  EXPORT ByBucketing(DATASET(Types.NumericField) d,
                     Types.t_Discrete N=ML_Core.Config.Discrete):= FUNCTION
    bck := ML_Core.FieldAggregates(d).Buckets(N); // Most of the work done by field aggregates
    RETURN PROJECT(bck,TRANSFORM(Types.DiscreteField,
                                 SELF.value := LEFT.bucket,
                                 SELF := LEFT));
  END;

  /*
     NTiles allocates a continuous variable into one of N groups such
     that each group contains roughly the same number of entries and
     that all of the elements of group 2 have a higher value that group
     1 etc.
  */
  EXPORT i_ByTiling(SET OF Types.t_FieldNumber f,
                    Types.t_Discrete N=ML_Core.Config.Discrete)
    := DATASET([{f,c_Method.Tiling,N,0,0}],r_Method);
  EXPORT ByTiling(DATASET(Types.NumericField) d,
                  Types.t_Discrete N=ML_Core.Config.Discrete) := FUNCTION
    bck := ML_Core.FieldAggregates(d).NTiles(N); // Most of the work done by field aggregates
    RETURN PROJECT(bck,TRANSFORM(Types.DiscreteField,
                                 SELF.value := LEFT.ntile,
                                 SELF := LEFT));
  END;

  /*
    This is an engine that can discretize all of the fields in a file;
    applying a different method to each if required.
    Note that the file d is read once for each instruction - so it is
    much better to combine the instructions for multiple fields into
    one (provided the parameters and method are the same)
  */
  EXPORT Do(DATASET(Types.NumericField) d,
            DATASET(r_Method) to_do) := FUNCTION
    DoOne(DATASET(Types.DiscreteField) sofar,
                  Types.t_Discrete c) := FUNCTION
      ThisLap := to_do[c];
      TheseFields := d(Number IN ThisLap.fields);
      this_res := CASE( ThisLap.method,
          c_Method.Rounding => ByRounding(TheseFields,ThisLap.rParam1,ThisLap.rParam2),
          c_Method.Bucketing => ByBucketing(TheseFields,ThisLap.iParam1),
          c_Method.Tiling => ByTiling(TheseFields,ThisLap.iParam1),
          DATASET([],Types.DiscreteField) );
      RETURN sofar+this_res;
    END;
    RETURN LOOP( DATASET([],Types.DiscreteField),
                COUNT(to_do), DoOne(ROWS(LEFT),COUNTER));
  END;

END;
