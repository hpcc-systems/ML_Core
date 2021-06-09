/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ AS MLC;
IMPORT $ AS Preprocessing;
IMPORT Preprocessing.Types AS Types;

NumericField := MLC.Types.NumericField;

/**
 * Split input data into training and test sets based on the split ratio. It requires the data has sequential id starting with 1.
 *
 * @param dataToSplit: DATASET(Types.NumericField).
 *   <p> The data to split.
 *
 * @param trainSize: REAL4, DEFAULT = 0.0.
 *   <p> The training size. If 0.0, it will be set as count(dataToSplit) - testSize.
 *
 * @param testSize: REAL4, DEFAULT = 0.0.
 *   <p> The test size. If 0.0, it will be set as count(dataToSplit) - trainSize.
 *
 * @param shuffle: Boolean, DEFAULT = false.
 *   <p> if true, the data is shuffled before splitting.
 *
 * @return training and test data
 */

EXPORT Split(DATASET(NumericField) dataToSplit, 
             REAL4 trainSize = 0.0, 
             REAL4 testSize = 0.0, 
             BOOLEAN shuffle = FALSE) := MODULE

  //Get the count of training and test sets
  SHARED idCount := MAX(dataToSplit, id);
  SHARED fieldCount := MAX(dataToSplit, number);
  SHARED errorMsg := 'Incorrect Train Size';
  SHARED trainCount := IF(trainSize >= 0.0 AND trainSize <= 1,
                             ROUND(idCount * trainSize) * fieldCount,
                                     ERROR(errorMsg));
  SHARED testCount := COUNT(dataToSplit) - trainCount;
  // Random Split the data without Shuffle
  SHARED nonShuffle_trainDS := dataTosplit(id <= ROUND(idCount * trainSize));
  SHARED nonShuffle_testDS := dataToSplit(id > ROUND(idCount * trainSize));

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
  SHARED Shuffle_trainDS := newDS( id <= ROUND(idCount * trainSize));
  SHARED Shuffle_testDS :=  newDS(id > ROUND(idCount * trainSize));

  // Export the splited datasets
  EXPORT trainData := IF(shuffle = FALSE, nonShuffle_trainDS, Shuffle_trainDS);
  EXPORT testData := IF(shuffle = FALSE, nonShuffle_testDS, Shuffle_testDS);

END;
