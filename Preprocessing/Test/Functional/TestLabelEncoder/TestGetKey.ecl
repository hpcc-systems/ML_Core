/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT Preprocessing.LabelEncoder as Encoder;

/**
 * Test GetKey function
 */
EXPORT TestGetKey := MODULE

  EXPORT KeyLayout := $.TestDataAndTypes.KeyLayout;

  /**
    * Test whether the keys are the same.
    *
    * @param k1: DATASET(KeyLayout).
    *   <p> the first key.
    *
    * @param k1: DATASET(KeyLayout).
    *   <p> the second key.
    *
    * @return True if the keys are equal, false otherwise.
    */
  EXPORT areEqualKeys(KeyLayout k1, KeyLayout k2) := FUNCTION
    Result := IF(k1.f1 = k2.f1 AND k1.f3 = k2.f3 AND k1.f4 = k2.f4, TRUE, FALSE);
    RETURN Result;
  END;

  /**
   * Test GetKey with a valid input
   */
  EXPORT testValidInput() := FUNCTION
    partialKey := ROW({[],[], ['low', 'med', 'high']}, KeyLayout);
    key := encoder.GetKey($.TestDataAndTypes.sampleData, partialKey);
    expectedKey := ROW({['cat1', 'cat2', 'cat3'], 
                        ['1000', '2000', '3000'], 
                        ['low', 'med', 'high']}, KeyLayout);
                        
    result := AreEqualKeys(key, expectedKey);
    RETURN ASSERT(result = TRUE, 'testValidInput Failed');
  END;
END;
