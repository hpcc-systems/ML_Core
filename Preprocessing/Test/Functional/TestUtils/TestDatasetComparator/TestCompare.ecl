/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^.^ as ML_Core;
DatasetComparator := ML_Core.Preprocessing.Utils.DatasetComparator;

/**
 * Test Compare function in DatasetComparator module.
 */
EXPORT TestCompare := MODULE
  SHARED sample1 := $.TestDataAndTypes.sample1;
  SHARED sample1_2 := $.TestDataAndTypes.sample1_2;
  SHARED sample2 := $.TestDataAndTypes.sample2;
  SHARED sample2_2 := $.TestDataAndTypes.sample2_2;
  
  /**
   * Testing with two equal datasets.
   */
  EXPORT TestEqualData() := FUNCTION
    result := DatasetComparator.Compare(sample1, sample1);
    RETURN ASSERT(result = 0, 'TestEqualData Failed');
  END;

  /**
   * Testing with two datasets with same type but different number of rows.
   */
  EXPORT TestDifferentNumberOfRows() := FUNCTION
    result := DatasetComparator.Compare(sample1, sample1_2);
    RETURN ASSERT(result = -2, 'TestDifferentNumberOfRows Failed');
  END;

  /**
   * Testing with two datasets with same number of rows and data structure
   * but differing at a row.
   */
  EXPORT TestRowDifference() := FUNCTION
    result := DatasetComparator.Compare(sample2, sample2_2);
    RETURN ASSERT(result = 2, 'TestRowDifference Failed');
  END;
END;