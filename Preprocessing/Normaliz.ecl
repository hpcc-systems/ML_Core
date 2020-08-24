/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as ML_Core;

PTypes := ML_Core.Preprocessing.Types;
normsLayout := ML_Core.Preprocessing.Types.Normaliz.NormsLayout;
NumericField := ML_Core.Types.NumericField;
t_FieldReal := ML_Core.Types.t_FieldReal;

/**
 * Compute L1 norm.
 * <p> Given a set of values, the L1 norm is the sum of absolute values.
 *
 * @param values: SET OF t_FieldReal.
 *   <p> The set of values from which the l1 norm will be determined.
 *
 * @return l1Norm: t_FieldReal.
 */
GetL1Norm(SET OF t_FieldReal values) := FUNCTION
  LoopLayout := RECORD
    UNSIGNED cnt;
    t_FieldReal sumOfAbs;
  END;

  initialResult := DATASET([{2, ABS(values[1])}], LoopLayout);
  loopResult := LOOP(initialResult,
                     COUNT(values) - 1,
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(LoopLayout,
                        SELF.sumOfAbs := LEFT.sumOfAbs + ABS(values[LEFT.cnt]);
                        SELF.cnt := LEFT.cnt + 1 )));

  l1Norm := loopResult[1].sumOfAbs;
  RETURN l1Norm;
END;

/**
 * Compute L2 norm.
 * <p> Given a set of values, the L2 norm is the square root of the sum of squares.
 *
 * @param values: SET OF t_FieldReal.
 *   <p> The set of values from which the l2 norm will be determined.
 *
 * @return l2Norm: t_FieldReal.
 */
GetL2Norm(SET OF t_FieldReal values) := FUNCTION
  LoopLayout := RECORD
    UNSIGNED cnt;
    t_FieldReal sumOfSquares;
  END;

  initialResult := DATASET([{2, POWER(values[1], 2)}], LoopLayout);
  loopResult := LOOP(initialResult,
                     COUNT(values) - 1,
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(LoopLayout,
                        SELF.sumOfSquares := LEFT.sumOfSquares + POWER(values[LEFT.cnt], 2);
                        SELF.cnt := LEFT.cnt + 1)));

  l2Norm := SQRT(loopResult[1].sumOfSquares);
  RETURN l2Norm;
END;

/**
 * Compute L-Infinty norm.
 * <p> Given a set of values the l-infinty norm is the value with highest absolute value.
 *
 * @param values: SET OF t_FieldReal.
 *   <p> the set of values from which the l-infinity norm will be determined.
 *
 * @return lInfintyNorm: t_FieldRead.
 */
GetLInfinityNorm(SET OF t_FieldReal values) := FUNCTION
  LoopLayout := RECORD
    UNSIGNED cnt;
    t_FieldReal maxMagnitude;
  END;
  
  //set initial maxMagnitude to absolute value of first value.
  initialResult := DATASET([{2, ABS(values[1])}], LoopLayout);

  //looping through the remaining values to find the maximum magnitude.
  loopResult := LOOP(initialResult,
                     COUNT(values) - 1,
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(LoopLayout,
                        SELF.maxMagnitude := IF(LEFT.maxMagnitude < ABS(values[LEFT.cnt]), 
                                                ABS(values[LEFT.cnt]), 
                                                LEFT.maxMagnitude);
                        SELF.cnt := LEFT.cnt + 1)));

  lInfintyNorm := loopResult[1].maxMagnitude;
  RETURN lInfintyNorm;
END;

/**
 * computes the norm for each row in the data.
 *
 * @param dataToNormalize: DATASET(Types.NumericField).
 *   <p> The data to normalize.
 *
 * @param norm: STRING3.
 *   <p> The norm based on which the data will be normalized.
 *
 * @return norms: DATASET(normsLayout).
 */
ComputeNorms(DATASET(NumericField) dataToNormalize, STRING3 norm) := FUNCTION
  normsLayout ComputeNorm (PTypes.idLayout L) := TRANSFORM
    SELF.id := L.id;
    values := SET(dataToNormalize(id = L.id), value);
    invalidNormError := ERROR('Invalid norm! Norm must be \'l1\', \'l2\' or \'inf\'');
    SELF.value := IF(norm = 'l1', GetL1Norm(values), 
                    IF(norm = 'l2', GetL2Norm(values), 
                      IF(norm = 'inf', GetLInfinityNorm(values), invalidNormError)));
  END;
  
  ids := DATASET(SET(dataToNormalize, id), PTypes.idLayout);
  uniqueIDs := DEDUP(ids);
  norms := PROJECT(uniqueIDs, ComputeNorm(LEFT));
  RETURN norms;
END;

/**
 * Allows to normalize data based on L1 norm, L2 norm or L-Infinty norm.
 *
 * @param dataToNormalize: DATASET(Types.NumericField)
 *   <p> The data to normalize.
 *
 * @param norm: STRING3, Default = 'l2'.
 *   <p> The norm based on which the data will be normalized.
 *   <p> valid values: 'l1', 'l2', 'inf'.
 *
 * @return the normalizedData: DATASET(NumericField).
 */
EXPORT Normaliz (DATASET(NumericField) dataToNormalize, STRING3 norm = 'l2') := FUNCTION
  norms_ := ComputeNorms(dataToNormalize, norm); //compute the norms
  
  //apply norm on each value
  NumericField normalizeRow (NumericField L) := TRANSFORM
    SELF.value := L.value/norms_(id = L.id)[1].value;
    SELF := L;
  END;

  normalizedData := PROJECT(dataToNormalize, normalizeRow(LEFT));
  RETURN normalizedData;
END;
