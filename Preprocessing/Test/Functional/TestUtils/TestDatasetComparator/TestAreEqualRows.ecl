/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^.^ as ML_Core;
DatasetComparator := ML_Core.Preprocessing.Utils.DatasetComparator;

/**
 * Test AreEqualRows function in DatasetComparator module.
 */
EXPORT TestAreEqualRows := MODULE
  SHARED sample1 := $.TestDataAndTypes.sample1;
  SHARED sample2 := $.TestDataAndTypes.sample2;
  
  /**
   * Testing with two equal rows
   */
  EXPORT TestEqualRows() := FUNCTION
    result := DatasetComparator.AreEqualRows(sample1[1], sample1[1]);
    RETURN ASSERT(result = TRUE, 'TestEqualRows Failed');
  END;

  /**
   * Testing with different rows
   */
  EXPORT TestDifferentRows() := FUNCTION
    result := DatasetComparator.AreEqualRows(sample1[1], sample2[1]);
    RETURN ASSERT(result = FALSE, 'TestDifferentRows Failed');
  END;
END;