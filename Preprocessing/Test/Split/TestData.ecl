/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^ as MLC;
IMPORT MLC.Preprocessing.PTypes;

EXPORT TestData := MODULE
  EXPORT Layout := RECORD
    UNSIGNED id;
    UNSIGNED f1;
    UNSIGNED f2;
    UNSIGNED f3;
    UNSIGNED f4;
  END;

  EXPORT sampleData := DATASET([{1,  1,  2,  3,  4},
                                {2,  5,  6,  7,  8},
                                {3,  9, 10, 11, 12},
                                {4, 13, 14, 15, 16}], Layout);
  
  EXPORT expTrainData := DATASET([{1, 1, 1,  1},
                                  {1, 1, 2,  2},
                                  {1, 1, 3,  3},
                                  {1, 1, 4,  4},
                                  {1, 2, 1,  5},
                                  {1, 2, 2,  6},
                                  {1, 2, 3,  7},
                                  {1, 2, 4,  8}], MLC.Types.NumericField);
  
  EXPORT expTestData := DATASET([{1, 1, 1,   9},
                                 {1, 1, 2,  10},
                                 {1, 1, 3,  11},
                                 {1, 1, 4,  12},
                                 {1, 2, 1,  13},
                                 {1, 2, 2,  14},
                                 {1, 2, 3,  15},
                                 {1, 2, 4,  16}], MLC.Types.NumericField);
END;