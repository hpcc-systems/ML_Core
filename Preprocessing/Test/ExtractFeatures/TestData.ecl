/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^ as MLC;
IMPORT Preprocessing.PTypes;

NumericField := MLC.Types.NumericField;

EXPORT TestData := MODULE  
  EXPORT sampleData := DATASET([{1, 1, 1, 1},
                                {1, 1, 2, 2},
                                {1, 1, 3, 3},
                                {1, 1, 4, 4},
                                {1, 2, 1, 5},
                                {1, 2, 2, 6},
                                {1, 2, 3, 7},
                                {1, 2, 4, 8}], NumericField);
  
  EXPORT expRemainder1 := DATASET([{1, 1, 1, 2},
                                   {1, 1, 2, 3},
                                   {1, 1, 3, 4},
                                   {1, 2, 1, 6},
                                   {1, 2, 2, 7},
                                   {1, 2, 3, 8}], NumericField);
  
  EXPORT expExtracted1 := DATASET([{1, 1, 1, 1},
                                   {1, 2, 1, 5}], NumericField);
  
  EXPORT expRemainder2 := DATASET([{1, 1, 1, 1},
                                   {1, 1, 2, 3},
                                   {1, 2, 1, 5},
                                   {1, 2, 2, 7}], NumericField);
  
  EXPORT expExtracted2 := DATASET([{1, 1, 1, 2},
                                   {1, 1, 2, 4},
                                   {1, 2, 1, 6},
                                   {1, 2, 2, 8}], NumericField);
END;