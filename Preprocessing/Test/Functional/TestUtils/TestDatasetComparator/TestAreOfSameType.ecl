/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT Preprocessing.Utils.DatasetComparator;

/**
 * Test AreOfSameType function in DatasetComparator module.
 */
EXPORT TestAreOfSameType := MODULE
  SHARED TestRecord1 := $.TestDataAndTypes.TestRecord1;
  SHARED TestRecord2 := $.TestDataAndTypes.TestRecord2;
  
  /**
   * Testing with two datasets with same and simple record structure.
   */
  EXPORT TestSameSimpleRecord() := FUNCTION
    dta1 := DATASET([{'a', 'b'}], TestRecord1);
    dta2 := DATASET([{'c', 'd'}], TestRecord1);
    result := DatasetComparator.AreOfSameType(dta1, dta2);
    RETURN ASSERT(result = TRUE, 'TestSameSimpleRecord Failed');
  END;
  
  /**
   * Testing with two datasets with same and complex record structure
   */
  EXPORT TestSameComplexRecord() := FUNCTION
    dta1 := DATASET([{0, 'a', 'b', 0, 'c', {'d', 'e'}, [{'a', 'b'}]}], TestRecord2);
    dta2 := DATASET([{1, 'c', 'd', 1, 'e', {'f', 'g'}, [{'a', 'b'}]}], TestRecord2);
    result := DatasetComparator.AreOfSameType(dta1, dta2);
    RETURN ASSERT(result = TRUE, 'TestSameComplexRecord Failed');
  END;

  /**
   * Testing with two datasets different record structure
   */
  EXPORT TestDifferentRecord() := FUNCTION
    dta1 := DATASET([{'a', 'b'}], TestRecord1);
    dta2 := DATASET([{1, 'c', 'd', 1, 'e', {'f', 'g'}, [{'a', 'b'}]}], TestRecord2);
    result := DatasetComparator.AreOfSameType(dta1, dta2);
    RETURN ASSERT(result = FALSE, 'TestDifferentRecord Failed');
  END;
END;