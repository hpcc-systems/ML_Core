/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;
IMPORT $.TestData;

Preprocessing := ML_Core.Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;

/**
  * Test Split function.
  */
EXPORT TestSplit := MODULE
  /**
    * Test with valid train size = 0.5.
    */
  EXPORT TestValidTrainSize() := FUNCTION
    splitResult := Preprocessing.Split(testData.sampleData, 0.5);
    expectedTrain := splitResult.trainData;
    expectedTest := splitResult.testData;
    cmp1 := comparator.compare(expectedTrain, testData.trainData);
    cmp2 := comparator.compare(expectedTest, testData.testData);
    RETURN ASSERT(cmp1 = 0 AND cmp2 = 0, 'TestValidTrainSize Failed (' + cmp1 + '|' + cmp2 + ')');
  END;

  /**
    * Test with valid test size = 0.5.
    */
  EXPORT TestValidTestSize() := FUNCTION
    splitResult := Preprocessing.Split(testData.sampleData,, 0.5);
    expectedTrain := splitResult.trainData;
    expectedTest := splitResult.testData;
    cmp1 := comparator.compare(expectedTrain, testData.trainData);
    cmp2 := comparator.compare(expectedTest, testData.testData);
    RETURN ASSERT(cmp1 = 0 AND cmp2 = 0, 'TestValidTestSize Failed (' + cmp1 + '|' + cmp2 + ')');
  END;

  /**
    * Test with valid train and test size.
    */
  EXPORT TestValidTrainTestSize() := FUNCTION
    splitResult := Preprocessing.Split(testData.sampleData,0.5 , 0.5);
    expectedTrain := splitResult.trainData;
    expectedTest := splitResult.testData;
    cmp1 := comparator.compare(expectedTrain, testData.trainData);
    cmp2 := comparator.compare(expectedTest, testData.testData);
    errorMsg := 'TestValidTrainTestSize Failed (' + cmp1 + '|' + cmp2 + ')';
    RETURN ASSERT(cmp1 = 0 AND cmp2 = 0, errorMsg);
  END;
END;