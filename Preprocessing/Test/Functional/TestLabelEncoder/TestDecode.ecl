/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Test Decode in LabelEncoder
  */
IMPORT $.^.^.^.^ as ML_Core;

Encoder := ML_Core.Preprocessing.LabelEncoder;
Comparator := ML_Core.Preprocessing.Utils.DatasetComparator;

EXPORT TestDecode:= MODULE
  SHARED encodedData1 := $.TestDataAndTypes.encodedData1;
  SHARED encodedData2 := $.TestDataAndTypes.encodedData2;
  SHARED decodedData1 := $.TestDataAndTypes.decodedData1;
  SHARED decodedData2 := $.TestDataAndTypes.decodedData2;  
  SHARED key := $.TestDataAndTypes.key;

  /**
    * Test decode with valid input
    */
  EXPORT TestValidInput() := FUNCTION
    result := encoder.decode(encodedData1, key);
    expected := decodedData1;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, cmp + ':TestValidInput Failed!');
  END;

  /**
    * Test decode with data having unknown categories (encoded as -1)
    */
  EXPORT TestUnknownCategories() := FUNCTION
    result := encoder.decode(encodedData2, key);
    expected := decodedData2;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, cmp + ':TestUnknownCategories Failed!');
  END;
END;