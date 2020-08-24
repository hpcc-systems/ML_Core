/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^.^ as ML_Core;
DatasetComparator := ML_Core.Preprocessing.Utils.DatasetComparator;

/**
 * Test GetFieldsInfo function in DatasetComparator module.
 */
EXPORT TestGetFieldsInfo := MODULE
  SHARED FieldInfo := DatasetComparator.Types.FieldInfo;
  SHARED TestRecord1 := $.TestDataAndTypes.TestRecord1;
  SHARED TestRecord2 := $.TestDataAndTypes.TestRecord2;
  
  /**
   * Test getting fields' info from a simple record structure.
   */
  EXPORT TestSimpleRecord() := FUNCTION
    testData := DATASET([{'a', 'b'}], TestRecord1);
    result := DatasetComparator.GetFieldsInfo(testData);
    expected := DATASET([{'0', 'field1', 'string', '10'}, {'1', 'field2', 'string', '20'}], FieldInfo);
    bothResults := MERGE(SORT(result, position), SORT(expected, position), SORTED(position));
    deduped := DEDUP(bothResults);
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestSimpleRecord Failed');
  END;
  
  /**
   * Test getting fields' info from a complex record structure.
   */
  EXPORT TestComplexRecord() := FUNCTION
    testData := DATASET([{0, 'a', 'b', 0, 'c', {'d', 'e'}, [{'a', 'b'}]}], TestRecord2);
    result := DatasetComparator.GetFieldsInfo(testData);
    expected := DATASET([{' 0', 'field1', 'unsigned', '4'}, 
                         {' 1', 'field2', 'string', '10'},
                         {' 2', 'field3', 'string', '-15'},
                         {' 3', 'field4', 'unsigned', '1'},
                         {' 4', 'field5', 'string', '20'},
                         {' 5', 'field6', 'testrecord1', '30'},
                         {' 6', 'field1', 'string', '10'},
                         {' 7', 'field2', 'string', '20'},
                         {' 8', 'field7', 'table of <unnamed>', '30'},
                         {' 9', 'field1', 'string', '10'},
                         {'10', 'field2', 'string', '20'}], FieldInfo);
    bothResults := MERGE(SORT(result, position), SORT(expected, position), SORTED(position));
    deduped := DEDUP(bothResults);
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestComplexRecord Failed');
  END;
END;