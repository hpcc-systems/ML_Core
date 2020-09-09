/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT Preprocessing.Utils.DatasetComparator;

/**
 * Test GetRowFieldsValues function in DatasetComparator module.
 */
EXPORT TestGetRowValuesAndTypes := MODULE
  SHARED FieldTypeAndValue := DatasetComparator.Types.FieldTypeAndValue;
  SHARED sample1 := $.TestDataAndTypes.sample1;
  
  /**
   * Testing with some valid input: first row of sample1
   */
  EXPORT TestValidInput() := FUNCTION
    result := DatasetComparator.GetRowValuesAndTypes(sample1[1]);
    expected := DATASET([{'boolean', '1'}, 
                         {'unsigned', '5'},
                         {'integer', '-8'},
                         {'decimal', '2.5'},
                         {'real', '2345.782470703125'},
                         {'string', 'sample1'},
                         {'qstring', '1'}], FieldTypeAndValue);
    bothResults := MERGE(SORT(result, dataType), SORT(expected, dataType), SORTED(dataType));
    deduped := DEDUP(bothResults);
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestSimpleRecord Failed');
  END;
END;