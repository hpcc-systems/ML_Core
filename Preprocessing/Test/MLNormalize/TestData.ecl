/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^ as MLC;
IMPORT Preprocessing.PTypes;

NormsRec := PTypes.MLNormalize.NormsRec;

EXPORT TestData := MODULE
  EXPORT Layout := RECORD
    UNSIGNED id;
    UNSIGNED f1;
    UNSIGNED f2;
    UNSIGNED f3;
    UNSIGNED f4;
  END;

  EXPORT sampleData := DATASET([{1, 4, 1, 2, 2},
                                {2, 1, 3, 9, 3},
                                {3, 5, 7, 5, 1}], Layout);
  
  EXPORT sklearnL1Norm := DATASET([{1,  9},
                                   {2, 16},
                                   {3, 18}], NormsRec);

  EXPORT sklearnL1NormalizedData := DATASET([{1, 1, 1, 0.44444444},
                                             {1, 1, 2, 0.11111111},
                                             {1, 1, 3, 0.22222222},
                                             {1, 1, 4, 0.22222222},
                                             {1, 2, 1,     0.0625},
                                             {1, 2, 2,     0.1875},
                                             {1, 2, 3,     0.5625},
                                             {1, 2, 4,     0.1875},
                                             {1, 3, 1, 0.27777778},
                                             {1, 3, 2, 0.38888889},
                                             {1, 3, 3, 0.27777778},
                                             {1, 3, 4, 0.05555556}], MLC.Types.NumericField);

  EXPORT sklearnL2Norm := DATASET([{1,  5},
                                   {2, 10},
                                   {3, 10}], NormsRec);
  
  EXPORT sklearnL2NormalizedData := DATASET([{1, 1, 1, 0.8},
                                             {1, 1, 2, 0.2},
                                             {1, 1, 3, 0.4},
                                             {1, 1, 4, 0.4},
                                             {1, 2, 1, 0.1},
                                             {1, 2, 2, 0.3},
                                             {1, 2, 3, 0.9},
                                             {1, 2, 4, 0.3},
                                             {1, 3, 1, 0.5},
                                             {1, 3, 2, 0.7},
                                             {1, 3, 3, 0.5},
                                             {1, 3, 4, 0.1}], MLC.Types.NumericField);
  
  EXPORT sklearnLInfNorm := DATASET([{1, 4},
                                     {2, 9},
                                     {3, 7}], NormsRec);
  
  EXPORT sklearnLInfNormalizedData := DATASET([{1, 1, 1,          1},
                                               {1, 1, 2,       0.25},
                                               {1, 1, 3,        0.5},
                                               {1, 1, 4,        0.5},
                                               {1, 2, 1, 0.11111111},
                                               {1, 2, 2, 0.33333333},
                                               {1, 2, 3,          1},
                                               {1, 2, 4, 0.33333333},
                                               {1, 3, 1, 0.71428571},
                                               {1, 3, 2,          1},
                                               {1, 3, 3, 0.71428571},
                                               {1, 3, 4, 0.14285714}], MLC.Types.NumericField);
END;