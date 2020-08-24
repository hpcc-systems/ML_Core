/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as MLC;
IMPORT Preprocessing.PTypes;

EXPORT TestData := MODULE
  EXPORT Layout := RECORD
    UNSIGNED id;
    REAL feature1;
    REAL feature2;
    REAL feature3;
  END;

  EXPORT ds := DATASET([{1, 0, -100.5, -500},
                        {2, 1, -200.5, -250},
                        {3, 2, -300.5,    0},
                        {4, 3, -400.5, 1000}], Layout);
  
  EXPORT sklearnKey := DATASET([{1,    1.5,   1.11803399},
                                {2, -250.5, 111.80339887},
                                {3,   62.5,  569.4020987}], PTypes.StandardScaler.keyRec);
  
  EXPORT sklearnScaledData := DATASET([{1, 1, 1, -1.34164079},
                                       {1, 1, 2,  1.34164079},
                                       {1, 1, 3, -0.98787834},
                                       {1, 2, 1,  -0.4472136},
                                       {1, 2, 2,   0.4472136},
                                       {1, 2, 3,  -0.5488213},
                                       {1, 3, 1,   0.4472136},
                                       {1, 3, 2,  -0.4472136},
                                       {1, 3, 3, -0.10976426},
                                       {1, 4, 1,  1.34164079},
                                       {1, 4, 2, -1.34164079},
                                       {1, 4, 3,   1.6464639}], MLC.Types.NumericField);
END;