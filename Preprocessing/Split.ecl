/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^ AS MLC;
IMPORT $ AS Preprocessing;
IMPORT Preprocessing.Types AS Types;

NumericField := MLC.Types.NumericField;

/**
 * Split input data into training and test sets based on the split ratio. It requires the data has
 * sequential id starting with 1.
 *
 * Curently does not support Myriad interface

 * @param dataToSplit: DATASET(Types.NumericField).
 *   <p> The data to split.
 *
 * @param splitRatio: REAL4, DEFAULT = 0.5.
 *   <p> The percentage of input data split as training data.
 *
 * @param shuffle: Boolean, DEFAULT = false.
 *   <p> if true, the data is shuffled before splitting.
 *
 * @return training and test data
 *
 * Note: currently not support Myraid interface.
 */

EXPORT Split(DATASET(NumericField) dataToSplit,
             REAL4 splitRatio = 0.0,
             BOOLEAN shuffle = FALSE) := MODULE

  //Get the count of training and test sets
  SHARED idCount := MAX(dataToSplit, id);
  SHARED fieldCount := MAX(dataToSplit, number);
  SHARED errorMsg := 'Incorrect Train Size';
  SHARED trainCount := IF(splitRatio >= 0.0 AND splitRatio <= 1,
                             ROUND(idCount * splitRatio) * fieldCount,
                                     ERROR(errorMsg));
  // Random Split the data without Shuffle
  SHARED nonShuffle_trainDS := dataTosplit(id <= ROUND(idCount * splitRatio));
  SHARED nonShuffle_testDS := ITERATE(SORT(dataToSplit(id > ROUND(idCount*splitRatio)),id, number),
                                       TRANSFORM(NumericField,
                                                 SELF.id := IF(LEFT.id = 0,
                                                               1,
                                                               IF( RIGHT.number > LEFT.number,
                                                                   LEFT.id,
                                                                   LEFT.id + 1)),
                                                 SELF:= RIGHT));
  // Random Split the data with Shuffle
  SHARED ids := PROJECT(TABLE(dataToSplit, {id}, id),
                            TRANSFORM(
                              {UNSIGNED4 id, UNSIGNED4 newID, UNSIGNED4 shuffleID},
                              SELF.newID := 0,
                              SELF.shuffleID := RANDOM(),
                              SELF.id := LEFT.id));

  SHARED addNewID := PROJECT(SORT(ids, shuffleID, LOCAL),
                                 TRANSFORM(RECORDOF(LEFT),
                                           SELF.newID := COUNTER,
                                           SELF := LEFT));
  SHARED newDS := JOIN(dataToSplit, addNewID,
                           LEFT.id = RIGHT.id,
                                  TRANSFORM(RECORDOF(dataToSplit),
                                               SELF.id := RIGHT.newID,
                                                     SELF := LEFT),
                                                        LOOKUP);
  SHARED Shuffle_trainDS := ITERATE(SORT(newDS( id <= ROUND(idCount*splitRatio)),id, number),
                                       TRANSFORM(NumericField,
                                                 SELF.id := IF(LEFT.id = 0,
                                                               1,
                                                               IF( RIGHT.number > LEFT.number,
                                                                   LEFT.id,
                                                                   LEFT.id + 1)),
                                                 SELF:= RIGHT));
  SHARED Shuffle_testDS := ITERATE(SORT(newDS( id > ROUND(idCount*splitRatio)),id, number),
                                       TRANSFORM(NumericField,
                                                 SELF.id := IF(LEFT.id = 0,
                                                               1,
                                                               IF( RIGHT.number > LEFT.number,
                                                                   LEFT.id,
                                                                   LEFT.id + 1)),
                                                 SELF:= RIGHT));
  // Export the splited datasets
  EXPORT trainData := IF(shuffle = FALSE, nonShuffle_trainDS, Shuffle_trainDS);
  EXPORT testData := IF(shuffle = FALSE, nonShuffle_testDS, Shuffle_testDS);

END;