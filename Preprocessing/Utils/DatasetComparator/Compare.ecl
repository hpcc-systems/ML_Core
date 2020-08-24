/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Compares any two datasets for equality.
  * <p> Only the following types are handled: 
  * BOOLEAN, UNSIGNED, INTEGER, DECIMAL, REAL, STRING AND QSTRING.
  * <p> Note: This implementation does not handle compound datatypes having child datasets
  * or complex record structures.
  *
  * @param dta1: ANY.
  *   <p>The first dataset.
  *
  * @param dta2: ANY.
  *   <p>The second dataset.
  *
  * @return 0 if the datasets are equal, 
  *   -1 if they have different record types,
  *   -2 if they have different number of rows,
  *   or a positive integer representing the first index at which they differ.
  */
EXPORT Compare(dta1, dta2) := FUNCTIONMACRO  
  //IMPORT ML_Core.Preprocessing.Utils.DatasetComparator as comp;
  IMPORT ML_Core.Preprocessing;

  #UNIQUENAME(comp)
  %comp% := Preprocessing.Utils.DatasetComparator;

  //Looping through rows and checking if they match
  #UNIQUENAME(RowsLoopStatus)
  %RowsLoopStatus% := RECORD
    UNSIGNED4 cnt;
    BOOLEAN isSameRow;
  END;
  
  #UNIQUENAME(startResult)
  %startResult% := DATASET([{1, True}], %RowsLoopStatus%);

  %RowsLoopStatus% XF (%RowsLoopStatus% L) := TRANSFORM
    SELF.isSameRow := %comp%.AreEqualRows(dta1[L.cnt], dta2[L.cnt]);
    SELF.cnt := L.cnt + 1;
  END;
  
  #UNIQUENAME(loopResult)
  %loopResult% := LOOP(%startResult%,
                     LEFT.isSameRow AND LEFT.cnt <= COUNT(dta1),
                     PROJECT(ROWS(LEFT), XF(LEFT)));
  
  #UNIQUENAME(comparisonResult)
  /*%comparisonResult% := IF(%comp%.AreOfSameType(dta1, dta2),
                           IF(COUNT(dta1) = COUNT(dta2), 
                           IF(%loopResult%[1].isSameRow, 0, %loopResult%[1].cnt - 1), -2), -1);*/
  
  %comparisonResult% := IF(COUNT(dta1) = COUNT(dta2), 
                           IF(%loopResult%[1].isSameRow, 0, %loopResult%[1].cnt - 1), 
                           -2);
  RETURN %comparisonResult%;
ENDMACRO;