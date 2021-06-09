/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Data and Record structures used by TestDatasetComparator Modules
  */
EXPORT TestDataAndTypes := MODULE
  //test record structures
  EXPORT TestRecord1 := RECORD
    STRING10 field1;
    STRING20 field2;
  END;
  
  EXPORT TestRecord2 := RECORD
    UNSIGNED4 field1;
    STRING10  field2;
    string    field3;
    UNSIGNED1 field4;
    STRING20  field5;
    TestRecord1 field6;
    DATASET(TestRecord1) field7;
  END;
  
  EXPORT TestRecord3 := RECORD
    BOOLEAN   field1;
    UNSIGNED4 field2;
    INTEGER   field3;
    DECIMAL   field4;
    REAL4     field5;
    STRING10  field6;
    QSTRING   field7;
  END;

  //sample data for testing
  EXPORT sample1 := DATASET([{True, 5, -8, 2.5, 2345.78238, 'sample1', '1'},
                             {True, 5, -8, 2.5, 2345.78238, 'sample1', '1'}], TestRecord3);
  EXPORT sample1_2 := DATASET([{True, 5, -8, 2.5, 2345.78238, 'sample1_2', '1_2'},
                               {True, 15, -18, 12.5, 23, 'sample1_2', '1_2'}], TestRecord3);

  EXPORT sample2 := DATASET([{False, 450, 1000, -21212.31, 9852.191, 'sample2', '2'},
                             {True, 450, 1000, -21212.31, 9852.191, 'sample2', '2'}], TestRecord3);
  EXPORT sample2_2 := DATASET([{False, 450, 1000, -21212.31, 9852.191, 'sample2', '2'},
                               {False, 450, 1000, -21212.31, 9852.191, 'sample2_2', '2_2'}], TestRecord3);
END;