/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

IMPORT $.^.^.^.^ as ML_Core;

Types := ML_Core.Types;
PTypes := ML_Core.Preprocessing.Types;

/**
  * Test Data for Testing OneHotEncoder
  */
EXPORT TestData := MODULE
  SHARED NumericField := Types.NumericField;

  EXPORT validFeatureIds := [1,3];
  EXPORT invalidFeatureIds := [1,4];

  EXPORT key := DATASET([{1, 1},
                         {1, 3}], PTypes.OneHotEncoder.cFeatures);

  EXPORT sample1 := DATASET([{1, 1, 1,     1},
                              {1, 1, 2, 1000},
                              {1, 1, 3,    3},
                              {1, 2, 1,    0},
                              {1, 2, 2, 2000},
                              {1, 2, 3,    1}], NumericField);
  EXPORT sample2 := DATASET([{1, 1, 1,     2},
                              {1, 1, 2, 1000},
                              {1, 1, 3,    1},
                              {1, 2, 1,    0},
                              {1, 2, 2, 2000},
                              {1, 2, 3,    2}], NumericField);
  EXPORT encodedSample1 := DATASET([{1, 1, 1,    0},
                                    {1, 1, 2,    1},
                                    {1, 1, 3, 1000},
                                    {1, 1, 4,    0},
                                    {1, 1, 5,    1},
                                    {1, 2, 1,    1},
                                    {1, 2, 2,    0},
                                    {1, 2, 3, 2000},
                                    {1, 2, 4,    1},
                                    {1, 2, 5,    0}], NumericField);
  EXPORT encodedSample2 := DATASET([{1, 1, 1,    0},
                                    {1, 1, 2,    1},
                                    {1, 1, 3, 1000},
                                    {1, 1, 4,    1},
                                    {1, 1, 5,    0},
                                    {1, 2, 1,    1},
                                    {1, 2, 2,    0},
                                    {1, 2, 3, 2000},
                                    {1, 2, 4,    0},
                                    {1, 2, 5,    1}], NumericField);
END;