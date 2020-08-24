/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as MLC;
IMPORT MLC.Preprocessing.PTypes;
IMPORT Preprocessing;

NumericField := MLC.Types.NumericField;
numberRec := Preprocessing.Utils.Types.numberRec;

EXPORT TestData := MODULE
  EXPORT Layout := RECORD
    UNSIGNED id;
    REAL f1;
    REAL f2;
    REAL f3;
  END;

  EXPORT ds := DATASET([{1, 1, 1000, 3},
                        {2, 0, 2000, 1}], Layout);
  
  EXPORT ds2 := DATASET([{1, 2, 1000, 1},
                         {2, 0, 2000, 2}], Layout);
  
  //ohe1 := DATASET([{0,1}], numberRec);
  //ohe2 := DATASET([{1,3}], numberRec);

  EXPORT expKey := DATASET([{1, 1, [{0},{1}]},
                            {2, 3, []},
                            {3, 4, [{1},{3}]}], PTypes.OneHotEncoder.keyRec);
  
  /*ohe1 := DATASET([{0,0,1,1},
                   {0,0,2,0}], NumericField);
  
  ohe2 := DATASET([{0,0,1,0},
                   {0,0,2,1}], NumericField);
  
  ohe3 := DATASET([{0,0,4,1},
                   {0,0,5,0}], NumericField);
  
  ohe4 := DATASET([{0,0,4,0},
                   {0,0,5,1}], NumericField);

  EXPORT expKey := DATASET([{1, 1, [{0, ohe1}, {1, ohe2}]},
                            {2, 3, []},
                            {3, 4, [{1, ohe3}, {3, ohe4}]}], PTypes.OneHotEncoder.keyRec);*/
  
  EXPORT expEncodedData1 := DATASET([{1, 1, 1,    0},
                                     {1, 1, 2,    1},
                                     {1, 1, 3, 1000},
                                     {1, 1, 4,    0},
                                     {1, 1, 5,    1},
                                     {1, 2, 1,    1},
                                     {1, 2, 2,    0},
                                     {1, 2, 3, 2000},
                                     {1, 2, 4,    1},
                                     {1, 2, 5,    0}], NumericField);
  
  EXPORT expDecodedData1 := DATASET([{1, 1, 1,     1},
                                      {1, 1, 2, 1000},
                                      {1, 1, 3,    3},
                                      {1, 2, 1,    0},
                                      {1, 2, 2, 2000},
                                      {1, 2, 3,    1}], NumericField);
  
  EXPORT expEncodedData2 := DATASET([{1, 1, 1,      0},
                                       {1, 1, 2,    0},
                                       {1, 1, 3, 1000},
                                       {1, 1, 4,    1},
                                       {1, 1, 5,    0},
                                       {1, 2, 1,    1},
                                       {1, 2, 2,    0},
                                       {1, 2, 3, 2000},
                                       {1, 2, 4,    0},
                                       {1, 2, 5,    0}], NumericField);
  
  EXPORT expDecodedData2 := DATASET([{1, 1, 1,    -1},
                                      {1, 1, 2, 1000},
                                      {1, 1, 3,    1},
                                      {1, 2, 1,    0},
                                      {1, 2, 2, 2000},
                                      {1, 2, 3,   -1}], NumericField);
END;