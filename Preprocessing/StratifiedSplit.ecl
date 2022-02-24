/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^ as ML_Core;
IMPORT ML_Core.Types as MTypes;

NumericField := ML_Core.Types.NumericField;


/**
 * Split input data into training and test sets based on the split ratio.
 * The result preservees the percentage of the samples for the specific feature or class.
 * It requires the data has sequential id starting with 1.
 *
 * Curently does not support Myriad interface.
 *
 * @param ds: DATASET(NumericField).
 *   The data to split.
 *
 * @param trainSize: REAL4, Default = 0.0
 *   <p> The training size.
 *
 * @param testSize: REAL4, Default = 0.0
 *   <p> The test size.
 *
 * @param labelId: UNSIGNED, Default = 0.
 *   <p> The number of the field whose proportions has to be maintained.
 *
 * @return the training data, test data as DATASET(NumericField).
 *
 */
EXPORT StratifiedSplit(DATASET(NumericField) ds,
                       REAL4 trainSize = 0, REAL4 testSize = 0, UNSIGNED labelId = 0,
                       BOOLEAN shuffle = FALSE) := MODULE
  //Get the count of training and test sets
  SHARED idCount := MAX(ds, id);
  SHARED fieldCount := MAX(ds, number);
  SHARED errorMsg := 'Incorrect input parameter(s)';
  SHARED trainCount := IF(trainSize >= 0.0 AND trainSize <= 1,
                                  ROUND(idCount * trainSize) * fieldCount,
                                                             ERROR(errorMsg));
  SHARED testCount := COUNT(ds) - trainCount;
  //Calculate the number of training records for each category
  SHARED ratio := TABLE(ds(number = labelID),
                       {value, cnt := COUNT(group),
                       ratio := COUNT(GROUP)/idCount,
                       trainCnt := ROUND(trainSize*COUNT(GROUP))},
                       value);
  SHARED l_IDs := RECORD
    UNSIGNED4 id;
    REAL value;
    UNSIGNED4 newID;
  END;
  // Aggregate the ids of each category
  SHARED ids := PROJECT(TABLE(ds(number = labelID), {id, value}, id, value),
                            TRANSFORM(
                              l_IDs,
                              SELF.newID := 0,
                              SELF.id := LEFT.id,
                              SELF.value := LEFT.value));

  SHARED newIDs := PROJECT(GROUP(SORT(ids, value), value),
                           TRANSFORM(l_IDs, SELF.newID := COUNTER,
                           SELF := LEFT));
  // Get the train and test set without shuffle
  SHARED nonshuffle_idRst := JOIN(GROUP(newIDs), ratio,
                                 LEFT.value = RIGHT.value,
                                 TRANSFORM({RECORDOF(LEFT), BOOLEAN ifTrain},
                                 SELF.ifTrain := IF(LEFT.newid <= RIGHT.trainCnt, TRUE, FALSE),
                                 SELF := LEFT));
  SHARED nonshuffle_dsRst :=JOIN(ds, nonshuffle_idRst,
                                LEFT.id = RIGHT.id,
                                TRANSFORM({NumericField, BOOLEAN ifTrain},
                                SELF.ifTrain := RIGHT.ifTrain,
                                SELF := LEFT));
  SHARED nonShuffle_trainDS := PROJECT(nonshuffle_dsRst(ifTrain = TRUE),
                                       TRANSFORM(MTypes.NumericField, SELF.id := COUNTER, SELF := LEFT));
  SHARED nonShuffle_testDS := PROJECT(nonshuffle_dsRst(ifTrain = FALSE),
                                       TRANSFORM(MTypes.NumericField, SELF.id := COUNTER, SELF := LEFT));
  // Get the train and test set without shuffle
  SHARED shuffle_idRst0 := JOIN(GROUP(newIDs), ratio,
                               LEFT.value = RIGHT.value,
                               TRANSFORM({RECORDOF(LEFT), BOOLEAN ifTrain, UNSIGNED4 shuffleID},
                               SELF.ifTrain := IF(LEFT.newid <= RIGHT.trainCnt, TRUE, FALSE),
                               SELF.shuffleID := RANDOM(),
                               SELF := LEFT));
  SHARED shuffle_idRst_train := PROJECT(SORT(shuffle_idRst0(ifTrain = TRUE), shuffleID),
                                              TRANSFORM(RECORDOF(LEFT), SELF.newID := COUNTER, SELF := LEFT));
  SHARED shuffle_idRst_test := PROJECT(SORT(shuffle_idRst0(ifTrain = FALSE), shuffleID),
                                              TRANSFORM(RECORDOF(LEFT), SELF.newID := COUNTER, SELF := LEFT));
  SHARED shuffle_idRst := shuffle_idRst_train + shuffle_idRst_test;

  SHARED shuffle_dsRst :=JOIN(ds, shuffle_idRst,
                              LEFT.id = RIGHT.id,
                              TRANSFORM({NumericField, BOOLEAN ifTrain},
                              SELF.id := RIGHT.newID,
                              SELF.ifTrain := RIGHT.ifTrain,
                              SELF := LEFT));

  SHARED Shuffle_trainDS := PROJECT(shuffle_dsRST(ifTrain = TRUE),
                                      TRANSFORM(NumericField, SELF := LEFT));
  SHARED Shuffle_testDS := PROJECT(shuffle_dsRST(ifTrain = FALSE),
                                      TRANSFORM(NumericField, SELF := LEFT));
  //Sanity check of the input parameters
  SHARED sanityCheck := FUNCTION
      labelCheck := IF(labelID >= 0 AND labelID <= fieldCount, TRUE, FALSE);
      trainSizeCheck := IF(trainSize >= 0 AND trainSize <= 1, TRUE, FALSE);
      testSizeCheck := IF(testSize >= 0 AND testSize <= 1, TRUE, FALSE);
    RETURN IF(labelCheck AND trainSizeCheck AND testSizeCheck, TRUE, FALSE);
  END;
  // EXPORT trainData := IF(sanityCheck, IF(shuffle = FALSE, nonShuffle_trainDS, Shuffle_trainDS), ERROR(errorMsg));
  // EXPORT testData := IF(sanityCheck, IF(shuffle = FALSE, nonShuffle_testDS, Shuffle_testDS),  ERROR(errorMsg));
  //Export the results
  EXPORT trainData := IF(shuffle = FALSE, nonShuffle_trainDS, Shuffle_trainDS);
  EXPORT testData := IF(shuffle = FALSE, nonShuffle_testDS, Shuffle_testDS);

END;
