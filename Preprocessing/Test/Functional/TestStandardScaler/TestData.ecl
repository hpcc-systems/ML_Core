/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;

Types := ML_Core.Types;
PTypes :=  ML_Core.Preprocessing.Types;

/**
  * Test data for testing standardScaler module
  */
EXPORT TestData := MODULE
  EXPORT key := DATASET([{1,    1.5,   1.11803399},
                        {2, -250.5, 111.80339887},
                        {3,   62.5,  569.4020987}], PTypes.StandardScaler.keyLayout);

  EXPORT sampleData := DATASET([{1, 1, 1,      0},
                                {1, 1, 2, -100.5},
                                {1, 1, 3,   -500},
                                {1, 2, 1,      1},
                                {1, 2, 2, -200.5},
                                {1, 2, 3,   -250},
                                {1, 3, 1,      2},
                                {1, 3, 2, -300.5},
                                {1, 3, 3,      0},
                                {1, 4, 1,      3},
                                {1, 4, 2, -400.5},
                                {1, 4, 3,   1000}], Types.NumericField);

  EXPORT scaledData := DATASET([{1, 1, 1, -1.34164079},
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
                                {1, 4, 3,   1.6464639}], Types.NumericField);
END;