/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;
t_FieldNumber := ML_Core.Types.t_FieldNumber;

/**
 * Resets the number ordering so that it starts from 1
 *
 * @param ds: DATASET(NumericField)
 *   the dataset whose number field needs to be reordered
 *
 * @return the dataset with ordered number field
 */
ResetNumber (DATASET(NumericField) ds) := FUNCTION
  IMPORT STD;
  currentNumbers := SET(ds(id = 1), number);
  numCount := (t_FieldNumber) COUNT(currentNumbers);

  NumericField reset (NumericField L, t_FieldNumber cnt) := TRANSFORM
    orderedNum := STD.MATH.FMOD(cnt, numCount);
    SELF.number := IF(orderedNum = 0, numCount, orderedNum);
    SELF := L;
  END;

  Result := PROJECT(ds, reset(LEFT, COUNTER));
  RETURN Result;
END;

/**
 * Extracts data of each feature in featureList from a given dataset
 *
 * @param ds: DATASET(NumericField)
 *   The dataset from which the features are extracted
 *
 * @param featureList: SET OF UNSIGNED
 *   The number of the features to be extracted
 *
 * @return remainder and extracted: DATASET(NumericField)
 *   remainder is the data without the features in featureList
 *   extracted is the data of the features in featureList
 */
EXPORT ExtractFeatures (DATASET(NumericField) ds, SET OF t_FieldNumber featureList) := FUNCTION
  part1 := ds(number NOT IN featureList);
  part2 := ds(number IN featureList);

  ResultRec := RECORD
    DATASET(NumericField) remainder;
    DATASET(NumericField) extracted;
  END;

  finalPart1 := resetNumber(part1);
  finalPart2 := resetNumber(part2);
 
  Result := ROW({finalPart1, finalPart2}, ResultRec);
  RETURN Result;
END;
