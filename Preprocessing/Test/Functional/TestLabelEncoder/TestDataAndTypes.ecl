/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Data and Record structures used by TestLabelEncoder Modules
  */
EXPORT TestDataAndTypes := MODULE
  //record structure for key.
  EXPORT KeyLayout := RECORD
    SET OF STRING f1;
    SET OF STRING f3;
    SET OF STRING f4;
  END;

  EXPORT key := ROW({['cat1', 'cat2', 'cat3'], 
                     ['1000', '2000', '3000'], 
                     ['low', 'med', 'high']}, KeyLayout);
  
  //Record structure for sample data
  EXPORT sampleDataLayout := RECORD
    UNSIGNED id;
    STRING   f1;   //categorical
    UNSIGNED f2;   //non-categorical
    UNSIGNED f3;   //categorical
    STRING   f4;   //categorical
  END;
  
  //sample data
  EXPORT sampleData := DATASET([{1, 'cat1',  4, 3000, 'high'},
                                {2, 'cat3',  5, 2000, 'med'},
                                {3, 'cat2',  6, 1000, 'low'}], sampleDataLayout);
  
  //sample data
  EXPORT sampleData2 := DATASET([{1, 'cat1',  4, 3000, 'highy'},
                                 {2,     '',  5, 2000, 'med'},
                                 {3, 'cat2',  6, 1000, 'low'}], sampleDataLayout);
  
  //record structure for encoded data
  EXPORT EncodedLayout := RECORD
    UNSIGNED id;
    INTEGER  f1;   //categorical
    UNSIGNED f2;   //non-categorical
    INTEGER  f3;   //categorical
    INTEGER  f4;   //categorical
  END;

  EXPORT encodedData1 := DATASET([{1, 0,  4, 2, 2},
                                  {2, 2,  5, 1, 1},
                                  {3, 1,  6, 0, 0}], EncodedLayout);
  
  EXPORT encodedData2 := DATASET([{1,  0,  4, 2, -1},
                                  {2, -1,  5, 1,  1},
                                  {3,  1,  6, 0,  0}], EncodedLayout);

  //record structure for encoded data
  EXPORT DecodedLayout := RECORD
    UNSIGNED id;
    STRING  f1;   //categorical
    UNSIGNED f2;   //non-categorical
    STRING  f3;   //categorical
    STRING  f4;   //categorical
  END;  
  
  EXPORT decodedData1 := DATASET([{1, 'cat1',  4, '3000', 'high'},
                                  {2, 'cat3',  5, '2000', 'med'},
                                  {3, 'cat2',  6, '1000', 'low'}], DecodedLayout);

  EXPORT decodedData2 := DATASET([{1, 'cat1',  4, 3000,    ''},
                                  {2,     '',  5, 2000, 'med'},
                                  {3, 'cat2',  6, 1000, 'low'}], DecodedLayout);
END;
