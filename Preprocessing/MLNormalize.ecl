/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;
IMPORT Preprocessing.Utils.Types as UTypes;
IMPORT Preprocessing.PTypes;

normsRec := PTypes.MLNormalize.NormsRec;
NumericField := MLC.Types.NumericField;

/**
 * Compute L1 norm
 * Given a set of values the L1 norm is the square root of the sum of squares
 *
 * @param values: SET OF REAL
 *   the set of values from which the l1 norm will be determined
 *
 * @return l1Norm
 */
GetL1Norm(SET OF REAL values) := FUNCTION
  LoopRec := RECORD
    UNSIGNED cnt;
    REAL sumOfAbs;
  END;

  initialResult := DATASET([{2, ABS(values[1])}], LoopRec);
  loopResult := LOOP(initialResult,
                     COUNT(values) - 1,
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(LoopRec,
                        SELF.sumOfAbs := LEFT.sumOfAbs + ABS(values[LEFT.cnt]);
                        SELF.cnt := LEFT.cnt + 1 )));

  l1Norm := loopResult[1].sumOfAbs;
  RETURN l1Norm;
END;

/**
 * Compute L2 norm
 * Given a set of values the L2 norm is the square root of the sum of squares
 *
 * @param values: SET OF REAL
 *   the set of values from which the l2 norm will be determined
 *
 * @return l2Norm
 */
GetL2Norm(SET OF REAL values) := FUNCTION
  LoopRec := RECORD
    UNSIGNED cnt;
    REAL sumOfSquares;
  END;

  initialResult := DATASET([{2, POWER(values[1], 2)}], LoopRec);
  loopResult := LOOP(initialResult,
                     COUNT(values) - 1,
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(LoopRec,
                        SELF.sumOfSquares := LEFT.sumOfSquares + POWER(values[LEFT.cnt], 2);
                        SELF.cnt := LEFT.cnt + 1)));

  l2Norm := SQRT(loopResult[1].sumOfSquares);
  RETURN l2Norm;
END;

/**
 * Compute L-Infinty norm
 * Given a set of values the l-infinty norm is the value with highest absolute value
 *
 * @param values: SET OF REAL
 *   the set of values from which the l-infinity norm will be determined
 *
 * @return lInfintyNorm
 */
GetLInfinityNorm(SET OF REAL values) := FUNCTION
  LoopRec := RECORD
    UNSIGNED cnt;
    REAL maxMagnitude;
  END;

  initialResult := DATASET([{2, ABS(values[1])}], LoopRec);
  loopResult := LOOP(initialResult,
                     COUNT(values) - 1,
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(LoopRec,
                        SELF.maxMagnitude := IF(LEFT.maxMagnitude < ABS(values[LEFT.cnt]), ABS(values[LEFT.cnt]), LEFT.maxMagnitude);
                        SELF.cnt := LEFT.cnt + 1)));

  lInfintyNorm := loopResult[1].maxMagnitude;
  RETURN lInfintyNorm;
END;

/**
 * computes the norm for each row in the data
 *
 * @param dataToNormalize: DATASET(Types.NumericField)
 *   The data to normalize
 *
 * @param norm: STRING3
 *   The norm based on which the data will be normalized
 *   valid values: 'l1', 'l2', 'inf'
 *
 * @return norms
 */
ComputeNorms(DATASET(NumericField) dataToNormalize, STRING3 norm) := FUNCTION
  normsRec ComputeNorm (UTypes.idRec currentRow) := TRANSFORM
    SELF.id := currentRow.val;
    values := SET(dataToNormalize(id = currentRow.val), value);
    invalidNormError := ERROR('Invalid norm! Norm must be \'l1\', \'l2\' or \'inf\'');
    SELF.value := IF(norm = 'l1', GetL1Norm(values), 
                    IF(norm = 'l2', GetL2Norm(values), 
                      IF(norm = 'inf', GetLInfinityNorm(values), invalidNormError)));
  END;
  
  ids := DATASET(SET(dataToNormalize, id), UTypes.idRec);
  uniqueIDs := DEDUP(ids);
  norms := PROJECT(uniqueIDs, ComputeNorm(LEFT));
  RETURN norms;
END;

/**
 * Allows to normalize data based on L1 norm, L2 norm or L-Infinty norm
 *
 * @param dataToNormalize: DATASET(Types.NumericField)
 *   The data to normalize
 *
 * @param norm: STRING3, Default = 'l2'
 *   The norm based on which the data will be normalized
 *   valid values: 'l1', 'l2', 'inf'
 *
 * @return the norms and the normalizedData
 */
EXPORT MLNormalize (DATASET(NumericField) dataToNormalize, STRING3 norm = 'l2') := FUNCTION
  norms_ := ComputeNorms(dataToNormalize, norm);

  NumericField normalizeRow (NumericField L) := TRANSFORM
    SELF.value := L.value/norms_(id = L.id)[1].value;
    SELF := L;
  END;

  normalizedData := PROJECT(dataToNormalize, normalizeRow(LEFT));

  ResultRec := RECORD
    DATASET(normsRec) norms;
    DATASET(NumericField) val;
  END;

  Result := ROW({norms_, normalizedData}, ResultRec);
  RETURN Result;
END;
