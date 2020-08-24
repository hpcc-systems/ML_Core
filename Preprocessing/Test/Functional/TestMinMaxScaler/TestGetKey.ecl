/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;

/**
  * Test GetKey
  */
EXPORT TestGetKey := MODULE
  /**
    * Test compute key
    */
  EXPORT TestComputeKey() := FUNCTION
    scaler := Preprocessing.MinMaxScaler($.TestData.sampleData);
    result := scaler.getKey();
    expected := $.TestData.key1;
    both := result & expected;
    deduped := DEDUP(SORT(both, lowBound, highBound));
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestComputeKey failed');
  END;

  /**
    * Test reusing key
    */
  EXPORT TestKeyReuse() := FUNCTION
    scaler := Preprocessing.MinMaxScaler(key := $.TestData.key1);
    result := scaler.getKey();
    expected := $.TestData.key1;
    both := result & expected;
    deduped := DEDUP(SORT(both, lowBound, highBound));
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestKeyReuse failed');
  END;

  /**
    * Test changing min and max val
    */
  EXPORT TestLowAndHighChange() := FUNCTION
    scaler := Preprocessing.MinMaxScaler($.TestData.sampleData, -100, 100);
    result := scaler.getKey();
    expected := $.TestData.key2;
    both := result & expected;
    deduped := DEDUP(SORT(both, lowBound, highBound));
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestLowAndHighChange failed');
  END;
END;