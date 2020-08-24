/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * compare two rows having same record structure.
  * <p> Only the following types are handled: 
  * BOOLEAN, UNSIGNED, INTEGER, DECIMAL, REAL, STRING AND QSTRING.
  * <p> Note: This implementation does not handle compound datatypes having child datasets
  * or complex record structures.
  *
  * @param r1: ANY ROW.
  *   <p> the first row.
  *
  * @param r2: ANY ROW.
  *   <p> the second row.
  *
  * @return True if the rows are equal, False otherwise
  */
  EXPORT AreEqualRows(r1, r2) := FUNCTIONMACRO
    IMPORT ML_Core.Preprocessing;

    #UNIQUENAME(dtaCmp)
    %dtaCmp% := Preprocessing.Utils.DatasetComparator;

    //Getting the fields' type and value for each row
    #UNIQUENAME(r1TypesAndValues)
    %r1TypesAndValues% := %dtaCmp%.GetRowValuesAndTypes(r1);
    #UNIQUENAME(r2TypesAndValues)
    %r2TypesAndValues% := %dtaCmp%.GetRowValuesAndTypes(r2);
    
    //Looping through fields and checking if they in both rows
    #UNIQUENAME(LoopRec)
    %LoopRec% := RECORD
      UNSIGNED4 cnt;
      BOOLEAN isEqual;
    END;
    
    #UNIQUENAME(initialResult)
    %initialResult% := DATASET([{1, True}], %LoopRec%);
    
    tolerance := 0.00001; //tolerance value for comparing reals

    %LoopRec% XF (%LoopRec% L) := TRANSFORM
      r1Type := %r1TypesAndValues%[L.cnt].dataType;
      r1Value := %r1TypesAndValues%[L.cnt].value;
      r2Type := %r2TypesAndValues%[L.cnt].dataType;
      r2Value := %r2TypesAndValues%[L.cnt].value;

      isSameType := r1Type = r2Type;
      isRealOrDecimal := r1Type = 'real' OR r1Type = 'decimal';
      isAlmostEqual := ABS((REAL)r1Value - (REAL)r2Value) < tolerance;
      isSameValue := IF(isRealOrDecimal, isAlmostEqual, r1Value = r2Value);
      
      SELF.isEqual := isSameType AND isSameValue;
      SELF.cnt := L.cnt + 1;
    END;
    
    #UNIQUENAME(loopResult)
    %loopResult% := LOOP(%initialResult%,
                      LEFT.isEqual AND LEFT.cnt <= COUNT(%r1TypesAndValues%),
                      PROJECT(ROWS(LEFT), XF(LEFT)));
    
    #UNIQUENAME(Result)
    %Result% := IF(COUNT(%r1TypesAndValues%) = COUNT(%r2TypesAndValues%), %loopResult%[1].isEqual, FALSE);
    RETURN %Result%;
ENDMACRO;