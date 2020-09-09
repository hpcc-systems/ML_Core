/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Test Encode in LabelEncoder
  */
IMPORT Preprocessing.LabelEncoder as Encoder;
IMPORT Preprocessing.Utils.DatasetComparator as Comparator;

EXPORT TestEncode := MODULE
  EXPORT sampleData := $.TestDataAndTypes.sampleData;
  EXPORT sampleData2 := $.TestDataAndTypes.sampleData2;  
  EXPORT key := $.TestDataAndTypes.key;

  /**
    * Test encode with valid input
    */
  EXPORT TestValidInput() := FUNCTION
    result := encoder.encode(sampleData, key);
    expected := $.TestDataAndTypes.encodedData1;
    RETURN ASSERT(Comparator.Compare(result, expected) = 0, 'TestValidInput Failed!');
  END;

  /**
    * Test encode with data having unknown categories
    */
  EXPORT TestUnknownCategories() := FUNCTION
    result := encoder.encode(sampleData2, key);
    expected := $.TestDataAndTypes.encodedData2;
    RETURN ASSERT(Comparator.Compare(result, expected) = 0, 'TestUnknownCategories Failed!');
  END;
END;