IMPORT $ AS ML_Core;
IMPORT ML_Core.Types;
/**
  * This module is used to turn a dataset of NumericFields into a dataset
  * of DiscreteFields.  This is not quite as trivial as it seems as there
  * are a number of different ways to make the underlying data discrete;
  * and even within one method there may be different parameters.
  * Further - it is quite probable that different methods are going to be
  * desired for each field.
  * <p>There are two methods of interfacing:<ul>
  *    <li>Call a discretization method directly to apply to all fields.</li>
  *    <li>Build a set of instructions on how to discretize each field and
  *      then call 'Do'.</li></ul>
  * <p>The record format 'r_Method is used to build the set of instructions in
  * the latter case.
  * <p>For each discretization method (e.g. ByRounding), there is a corresponding
  * attribute preceded by 'i_' that is used to build the r_Method instruction for
  * using that method (e.g. i_ByRounding).
  * <p>Three methods are currently provided:<ul>
  * <li>ByRounding -- Numerically round the number to the nearest integer.</li>
  * <li>ByBucketing -- Split the range of each variable into a number of evenly
  *                    spaced buckets.</li>
  * <li>ByTiling -- Splits the datapoints into an ordered set of equal-sized groups.</li></ul>
  *
  **/
EXPORT Discretize := MODULE
  /**
    * Enumerate the available discretization methods.
    * @value Rounding = 1
    * @value Bucketing = 2
    * @value Tiling = 3
    **/
  EXPORT c_Method := ENUM(Rounding,Bucketing,Tiling);
  /**
    * This format is used to construct an 'instruction stream' to allow a dataset to be discretized according
    * to a set of instructions which are in (meta)data.
    * It can be created directly, though the preferred method is to call i_ByRounding(...), i_ByBucketing(...),
    * or i_ByTiling(...) to create each record.
    * @field method Indicator of the method to use (see c_method).
    * @field iParam1 The first integer parameter to the discretization method.
    * @field rParam1 The first real parameter.
    * @field rParam2 The second real parameter.
    **/
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
  /**
    * Construct an instruction (rMethod) that will cause certain
    * fields to be discretized by rounding.  See ByRounding below.
    * @param f A set of field numbers to which to apply this method.
    * @param Scale (Optional) A number by which to multiply each field
    *              before rounding.
    * @param Delta (Optional) An offset that is applied after scaling
    *              but before rounding.
    * @return DATASET(r_Method) containing one record.
    **/
  EXPORT i_ByRounding(SET OF Types.t_FieldNumber f,
                      REAL Scale=1.0,REAL Delta=0.0)
  := DATASET([{f,c_Method.Rounding,0,Scale,Delta}],r_Method);
  /**
    * Round the values passed in to create a discrete element
    * Scale is applied (by multiplication) first and can be used to
    * bring the data into a desired range (rParam1), Delta is applied
    * (by addition) second and can be used to re-base a range
    * OR to cause truncation or roundup as required (rParam2).
    * @param d The NumericField dataset to be discretized.
    * @param Scale (Optional) A number by which to multiply each field
    *        before rounding.
    * @param Delta (Optional) An offset that is applied after scaling
    *              but before rounding.
    * @return DATASET(DiscreteField) containing the discretized dataset.
    *
    **/
  EXPORT ByRounding(DATASET(Types.NumericField) d,REAL Scale=1.0,
                    REAL Delta=0.0)
  := PROJECT(d,TRANSFORM(Types.DiscreteField,
                          SELF.Value := ROUND(LEFT.Value*Scale+Delta),
                          SELF := LEFT));

  /**
    * Construct an instruction (rMethod) that will cause certain
    * fields to be discretized by bucketing.  See ByBucketing below.
    * @param f A set of field numbers to which to apply this method.
    * @param N (Optional) The number of buckets into which to split
    *                     the range.  The default is to use the ML_Core.
    *                     Config.Discrete configuration parameter.
    * @return DATASET(r_Method) containing one record.
    **/
  EXPORT i_ByBucketing(SET OF Types.t_FieldNumber f,
                       Types.t_Discrete N=ML_Core.Config.Discrete)
    := DATASET([{f,c_Method.Bucketing,N,0,0}],r_Method);
  /**
    * Allocates a continuous variable into one of N buckets
    * based upon an equal division of the RANGE of the variable.
    * <p>The buckets will NOT have an even number of elements unless
    * the underlying distribution of the variable is uniform.
    * @param d The NumericField dataset to be discretized.
    * @param N (Optional) The number of buckets into which to split
    *                     the range.  The default is to use the ML_Core.
    *                     Config.Discrete configuration parameter.
    * @return DATASET(DiscreteField) containing the discretized dataset.
    **/
  EXPORT ByBucketing(DATASET(Types.NumericField) d,
                     Types.t_Discrete N=ML_Core.Config.Discrete):= FUNCTION
    bck := ML_Core.FieldAggregates(d).Buckets(N); // Most of the work done by field aggregates
    RETURN PROJECT(bck,TRANSFORM(Types.DiscreteField,
                                 SELF.value := LEFT.bucket,
                                 SELF := LEFT));
  END;
  /**
    * Construct an instruction (rMethod) that will cause certain
    * fields to be discretized by tiling.  See ByTiling below.
    * @param f A set of field numbers to which to apply this method.
    * @param N (Optional) The number of tiles into which to split
    *                     the data.  The default is to use the ML_Core.
    *                     Config.Discrete configuration parameter.
    * @return DATASET(r_Method) containing one record.
    **/
  EXPORT i_ByTiling(SET OF Types.t_FieldNumber f,
                    Types.t_Discrete N=ML_Core.Config.Discrete)
    := DATASET([{f,c_Method.Tiling,N,0,0}],r_Method);
  /**
    * Allocate a continuous variable into one of N groups such
    * that each group (tile) contains roughly the same number of entries and
    * that all of the elements of group 2 have a higher value than group
    * 1, etc.
    * @param d The NumericField dataset to be discretized.
    * @param N (Optional) The number of tiles to create.
    *                     The default is to use the ML_Core.
    *                     Config.Discrete configuration parameter.
    * @return DATASET(DiscreteField) containing the discretized dataset.
    **/
  EXPORT ByTiling(DATASET(Types.NumericField) d,
                  Types.t_Discrete N=ML_Core.Config.Discrete) := FUNCTION
    bck := ML_Core.FieldAggregates(d).NTiles(N); // Most of the work done by field aggregates
    RETURN PROJECT(bck,TRANSFORM(Types.DiscreteField,
                                 SELF.value := LEFT.ntile,
                                 SELF := LEFT));
  END;

  /**
    * Execute a set of discretization instructions in order to discretize
    * all of the fields of the dataset using the appropriate methods.
    * <p>Note that the file d is read once for each instruction - so it is
    * much better to combine the instructions for multiple fields into
    * one (provided the parameters and method are the same).
    * @param d The NumericField dataset to be dicretized.
    * @param to_do The DATASET(r_Method) that contains the discretization
    *              instructions.
    * @return DATASET(DiscreteField) containing the discretized dataset.
    **/
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
