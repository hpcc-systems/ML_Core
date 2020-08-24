IMPORT $.^.^.^ as MLC;
IMPORT MLC.PTypes;

EXPORT TestData := MODULE
  EXPORT Layout := RECORD
    UNSIGNED id;
    STRING   f1;   //categorical
    UNSIGNED f2;   //non-categorical
    UNSIGNED f3;   //categorical
    STRING   f4;   //categorical
  END;

  EXPORT EncodedLayout := RECORD
    UNSIGNED id;
    INTEGER f1;   //categorical
    INTEGER f2;   //non-categorical
    INTEGER f3;   //categorical
    INTEGER f4;   //categorical
  END;

  EXPORT DecodedLayout := RECORD
    UNSIGNED id;
    STRING f1;   //categorical
    UNSIGNED f2; //non-categorical
    STRING f3;   //categorical
    STRING f4;   //categorical
  END;

  EXPORT KeyRec := RECORD
    SET OF STRING f1;
    SET OF STRING f3;
    SET OF STRING f4;
  END;

  EXPORT ds := DATASET([{1, 'cat1',  4, 3000, 'high'},
                    {2, 'cat3',  5, 2000, 'med'},
                    {3, 'cat2',  6, 1000, 'low'}], Layout);
  
  EXPORT ds2 := DATASET([{1, 'cat4',  4, 3000, 'high'},
                    {2, 'cat3',  5, 5000, 'med'},
                    {3, 'cat2',  6, 1000, 'low'}], Layout);
    
  EXPORT expKey := DATASET([{['cat1', 'cat2', 'cat3'], ['1000', '2000', '3000'], ['low', 'med', 'high']}], KeyRec);
  
  EXPORT expEncodedData1 := DATASET([{1, 0,  4, 2, 2},
                                      {2, 2,  5, 1, 1},
                                      {3, 1,  6, 0, 0}], EncodedLayout);
  
  EXPORT expDecodedData1 := DATASET([{1, 'cat1',  4, '3000', 'high'},
                                     {2, 'cat3',  5, '2000',  'med'},
                                     {3, 'cat2',  6, '1000',  'low'}], DecodedLayout);
  
  EXPORT expEncodedData2 := DATASET([{1, -1,  4, 2, 2},
                                      {2, 2,  5, -1, 1},
                                      {3, 1,  6, 0, 0}], EncodedLayout);
  
  EXPORT expDecodedData2 := DATASET([{1,     '',  4, '3000', 'high'},
                                     {2, 'cat3',  5,     '',  'med'},
                                     {3, 'cat2',  6, '1000',  'low'}], DecodedLayout);
END;