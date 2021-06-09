/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;
NumericField := ML_Core.Types.NumericField;

/**
  * Test Encode
  */
EXPORT TestEncode := MODULE
  SHARED sample1 := $.testData.sample1;
  SHARED sample2 := $.testData.sample2;
  SHARED key := $.testData.key;
  SHARED encoder := Preprocessing.OneHotEncoder(key := key);
  /**
    * Test with known categories.
    */
  EXPORT testKnownCategories() := FUNCTION    
    result := encoder.encode(sample1);
    expected := $.TestData.encodedSample1;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, cmp + ':testKnownCategories Failed!');
  END;

  /**
    * Test with unknown categories.
    */
  EXPORT testUnKnownCategs() := FUNCTION
    result := encoder.encode(sample2);
    expected := $.TestData.encodedSample2;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, cmp + ':testUnKnownCategs Failed!');
  END;

  /**
    * Test encoding empty data
    */
  EXPORT testEmptyInput() := FUNCTION
    emptyNF := DATASET([], NumericField);
    result := encoder.encode(emptyNF);
    expected := emptyNF;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, cmp + ':testEmptyInput Failed!');
  END;
END;