/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^ as ML_Core;
IMPORT ML_Core.Types AS MTypes;

/**
 * Normalizer
 * Normalizes each sample to its unit norm (row-wise normalization) with below options
 *
 * L1 norm.
 * <p> Given a set of values, the L1 norm is the sum of absolute values.
 *
 * L2 norm.
 * <p> Given a set of values, the L2 norm is the square root of the sum of squares.
 *
 * L-Infinty norm.
 * <p> Given a set of values the l-infinty norm is the value with highest absolute value.
 *
 * @param dataToNormalize: DATASET(Types.NumericField)
 *   <p> The data to normalize.
 *
 * @param norm: STRING3, Default = 'l2'.
 *   <p> The norm based on which the data will be normalized.
 *   <p> valid values: 'l1', 'l2', 'inf'.
 *
 * @return the normalizedData: DATASET(NumericField).
 *
 * Curently does not support Myriad interface.
 */

EXPORT Normalizer (DATASET(MTypes.NumericField) dataToNormalize, STRING3 norm = 'l2') := FUNCTION
    // Compute the norms
    norms := TABLE(dataToNormalize,
                   {wi, id, l1 := SUM(GROUP, ABS(value)), l2 := SQRT(SUM(GROUP, POWER(value,2))),
                   inf := MAX(GROUP, ABS(value))}, wi, id);
    // Normalize the data based on the computed norms
    l1Rst := JOIN(dataToNormalize,norms,
                 LEFT.wi = RIGHT.wi AND LEFT.id = RIGHT.id,
                 TRANSFORM(RECORDOF(LEFT), SELF.value := LEFT.value/RIGHT.l1, SELF := LEFT),
                 LOOKUP);
    l2Rst := JOIN(dataToNormalize,norms,
                 LEFT.wi = RIGHT.wi AND LEFT.id = RIGHT.id,
                 TRANSFORM(RECORDOF(LEFT), SELF.value := LEFT.value/RIGHT.l2, SELF := LEFT),
                 LOOKUP);
    infRst := JOIN(dataToNormalize, norms,
                   LEFT.wi = RIGHT.wi AND LEFT.id = RIGHT.id,
                   TRANSFORM(RECORDOF(LEFT), SELF.value := LEFT.value/RIGHT.inf, SELF := LEFT),
                   LOOKUP);
    // Return the norm. Or return the original data if the norm is not defined.
    normalizedData := IF(norm = 'l2', l2Rst,
                         IF(norm = 'l1', l1Rst,
                            IF(norm = 'inf', infRst, dataToNormalize)));
  RETURN normalizedData;
END;
