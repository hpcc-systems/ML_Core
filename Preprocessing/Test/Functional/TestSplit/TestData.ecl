/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;

/**
  * Test data for testing split function
  */
EXPORT testData := MODULE
  EXPORT sampleData := DATASET([{1, 1, 1,  1},
                                {1, 1, 2,  2},
                                {1, 1, 3,  3},
                                {1, 1, 4,  4},
                                {1, 2, 1,  5},
                                {1, 2, 2,  6},
                                {1, 2, 3,  7},
                                {1, 2, 4,  8},
                                {1, 3, 1,  9},
                                {1, 3, 2, 10},
                                {1, 3, 3, 11},
                                {1, 3, 4, 12},
                                {1, 4, 1, 13},
                                {1, 4, 2, 14},
                                {1, 4, 3, 15},
                                {1, 4, 4, 16}], NumericField);
  
  EXPORT trainData := DATASET([{1, 1, 1,  1},
                                {1, 1, 2,  2},
                                {1, 1, 3,  3},
                                {1, 1, 4,  4},
                                {1, 2, 1,  5},
                                {1, 2, 2,  6},
                                {1, 2, 3,  7},
                                {1, 2, 4,  8}], NumericField);
  
  EXPORT testData := DATASET([{1, 1, 1,   9},
                              {1, 1, 2,  10},
                              {1, 1, 3,  11},
                              {1, 1, 4,  12},
                              {1, 2, 1,  13},
                              {1, 2, 2,  14},
                              {1, 2, 3,  15},
                              {1, 2, 4,  16}], NumericField);
END;