/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
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
  
  EXPORT sklearnKey := DATASET([{1,      0,      3},
                                {2, -400.5, -100.5},
                                {3,   -500,   1000}], PTypes.MinMaxScaler.keyRec);
  
  EXPORT sklearnScaledData := DATASET([{1, 1, 1,          0},
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
                                       {1, 4, 3,          1}], MLC.Types.NumericField);
  
  EXPORT sklearnScaledData2 := DATASET([{1, 1, 1,        -100},
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
                                       {1, 4, 3,          100}], MLC.Types.NumericField);
END;