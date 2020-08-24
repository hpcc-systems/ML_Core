/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
  * Compares the data types of any two datasets.
  *
  * @param dta1: ANY.
  *   <p>The first dataset.
  *
  * @param dta2: ANY.
  *   <p>The second dataset.
  *
  * @return True if the types are the same, false otherwise.
  */
EXPORT AreOfSameType(dta1, dta2) := FUNCTIONMACRO
  IMPORT ML_Core.Preprocessing;
  
  #UNIQUENAME(dc)
  %dc% := Preprocessing.Utils.DatasetComparator;
  //Getting the fields' information for each data
  #UNIQUENAME(dta1FieldsInfo)
  %dta1FieldsInfo% := %dc%.GetFieldsInfo(dta1);
  #UNIQUENAME(dta2FieldsInfo)
  %dta2FieldsInfo% := %dc%.GetfieldsInfo(dta2);
  
  //Looping through fields and checking if fields at same position matches
  #UNIQUENAME(LoopLayout)
  %LoopLayout% := RECORD
    UNSIGNED4 cnt;
    BOOLEAN isSameField;
  END;
  
  #UNIQUENAME(initialResult)
  %initialResult% := DATASET([{1, True}], %LoopLayout%);

  %LoopLayout% XF (%LoopLayout% L) := TRANSFORM
    isSamePosition := %dta1FieldsInfo%[L.cnt].position = %dta2FieldsInfo%[L.cnt].position;
    isSameName := %dta1FieldsInfo%[L.cnt].name = %dta2FieldsInfo%[L.cnt].name;
    isSameSize := %dta1FieldsInfo%[L.cnt].size = %dta2FieldsInfo%[L.cnt].size;
    isSameType := %dta1FieldsInfo%[L.cnt].dataType = %dta2FieldsInfo%[L.cnt].dataType;
    SELF.isSameField := isSamePosition AND isSameName AND isSameSize AND isSameType;
    SELF.cnt := L.cnt + 1;
  END;
  
  #UNIQUENAME(cmpResult)
  %cmpResult% := LOOP(%initialResult%,
                     LEFT.isSameField AND LEFT.cnt <= COUNT(%dta1FieldsInfo%),
                     PROJECT(ROWS(LEFT), XF(LEFT)));
  
  #UNIQUENAME(Result)
  %Result% := IF(COUNT(%dta1FieldsInfo%) = COUNT(%dta2FieldsInfo%), %cmpResult%[1].isSameField, FALSE);
  RETURN %Result%;
ENDMACRO;