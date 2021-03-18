/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

/**
  * Test data for testing the Normaliz function
  */
EXPORT testData := MODULE
  EXPORT sampleData := DATASET([{1,1,1,4},
                                {1,1,2,1},
                                {1,1,3,2},
                                {1,1,4,2},
                                {1,2,1,1},
                                {1,2,2,3},
                                {1,2,3,9},
                                {1,2,4,3},
                                {1,3,1,5},
                                {1,3,2,7},
                                {1,3,3,5},
                                {1,3,4,1}], ML_Core.Types.NumericField);
  
  EXPORT l1NormResult := DATASET([{1, 1, 1, 0.44444444},
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
                                  {1, 3, 4, 0.05555556}], ML_Core.Types.NumericField);
  
  EXPORT l2NormResult := DATASET([{1, 1, 1, 0.8},
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
                                  {1, 3, 4, 0.1}], ML_Core.Types.NumericField);
  
  EXPORT lInfNormResult := DATASET([{1, 1, 1,          1},
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
                                    {1, 3, 4, 0.14285714}], ML_Core.Types.NumericField);
END;