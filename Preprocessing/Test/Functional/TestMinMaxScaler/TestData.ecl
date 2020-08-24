/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

Types := ML_Core.Types;
PTypes :=  ML_Core.Preprocessing.Types;

/**
  * Test data for testing standardScaler module
  */
EXPORT TestData := MODULE
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
                                {1, 4, 3,   1000}], ML_Core.Types.NumericField);
  
  EXPORT key1 := DATASET([{0.0, 1.0, [{1,      0,      3},
                                      {2, -400.5, -100.5},
                                      {3,   -500,   1000}]}], PTypes.MinMaxScaler.KeyLayout);
  
  EXPORT key2 := DATASET([{-100, 100, [{1,      0,      3},
                                      {2, -400.5, -100.5},
                                      {3,   -500,   1000}]}], PTypes.MinMaxScaler.KeyLayout);

  EXPORT scaledData1 := DATASET([{1, 1, 1,          0},
                                {1, 1, 2,          1},
                                {1, 1, 3,          0},
                                {1, 2, 1, 0.33333333},
                                {1, 2, 2, 0.66666667},
                                {1, 2, 3, 0.16666667},
                                {1, 3, 1, 0.66666667},
                                {1, 3, 2, 0.33333333},
                                {1, 3, 3, 0.33333333},
                                {1, 4, 1,          1},
                                {1, 4, 2,          0},
                                {1, 4, 3,          1}], ML_Core.Types.NumericField);
  
  EXPORT scaledData2 := DATASET([{1, 1, 1,        -100},
                                {1, 1, 2,          100},
                                {1, 1, 3,         -100},
                                {1, 2, 1, -33.33333333},
                                {1, 2, 2,  33.33333333},
                                {1, 2, 3, -66.66666667},
                                {1, 3, 1,  33.33333333},
                                {1, 3, 2, -33.33333333},
                                {1, 3, 3, -33.33333333},
                                {1, 4, 1,          100},
                                {1, 4, 2,         -100},
                                {1, 4, 3,          100}], ML_Core.Types.NumericField);
END;