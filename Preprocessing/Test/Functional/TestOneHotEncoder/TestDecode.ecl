/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;
IMPORT Preprocessing.Utils.DatasetComparator as Comparator;
IMPORT $.^.^.^.^.Types as T;

/**
  * Test decode.
  */
EXPORT TestDecode := MODULE
  SHARED encoder := Preprocessing.OneHotEncoder(key := $.testData.key);

  /**
    * Test GetNumberMapping.
    */
  EXPORT TestGetNumberMapping() := FUNCTION
    input := DATASET([{1},{2},{3},{4},{5}], Preprocessing.Types.numberLayout);
    result := encoder.GetNumberMapping(input);
    expected := DATASET([{1,1},
                          {2,1},
                          {3,2},
                          {4,3},
                          {5,3}], Preprocessing.Types.OneHotEncoder.NumberMapping);
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestGetNumberMapping Failed (' + cmp + ')');
  END;

  /**
    * Test decoding data with known categories.
    */
  EXPORT TestKnownCategories() := FUNCTION
    result := encoder.decode($.TestData.encodedSample1);
    expected := $.TestData.sample1;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestKnownCategories Failed (' + cmp + ')');
    //RETURN result;
  END;

  /**
    * Test decoding data with unknown categories.
    */
  EXPORT TestUnKnownCategories() := FUNCTION
    result := encoder.decode($.TestData.encodedSample2);
    expected := $.TestData.decodedSample2;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestUnKnownCategories Failed (' + cmp + ')');
    //RETURN result;
  END;

  /**
    * Test decoding empty data.
    */
  EXPORT testEmptyInput() := FUNCTION
    emptyNF := DATASET([], T.NumericField);
    result := encoder.decode(emptyNF);
    expected := emptyNF;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestEmptyData Failed (' + cmp + ')');
  END;
END;
