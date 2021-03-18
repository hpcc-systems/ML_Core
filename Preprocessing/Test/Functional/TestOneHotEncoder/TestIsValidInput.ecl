/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;

/**
  * Test isValidInput
  */
EXPORT TestIsValidInput := MODULE
  SHARED sampleData := $.testData.sample1;
  SHARED featureIds := $.testData.validFeatureIds;
  SHARED key := $.testData.key;

  /**
    * Test when baseData and featureIds are passed
    */
  EXPORT TestWhenDataPassed() := FUNCTION
    encoder := Preprocessing.OneHotEncoder(sampleData, featureIds);
    result := encoder.isValidInput();
    RETURN ASSERT(result = True, 'TestWhenDataPassed Failed!');
  END;

  /**
    * Test when key is passed
    */
  EXPORT TestWhenKeyPassed() := FUNCTION
    encoder := Preprocessing.OneHotEncoder(key := key);
    result := encoder.isValidInput();
    RETURN ASSERT(result = True, 'TestWhenKeyPassed Failed!');
  END;

  /**
    * Test when nothing passed
    */
  EXPORT TestWhenAllEmpty() := FUNCTION
    encoder := Preprocessing.OneHotEncoder();
    result := encoder.isValidInput();
    RETURN ASSERT(result = False, 'TestWhenAllEmpty Failed!');
  END;

  /**
    * Test when data passed but not featureIds
    */
  EXPORT TestEmptyFeatureIds() := FUNCTION
    encoder := Preprocessing.OneHotEncoder(sampleData);
    result := encoder.isValidInput();
    RETURN ASSERT(result = False, 'TestEmptyFeatureIds Failed!');
  END;
END;