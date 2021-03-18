/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
  * Allows to get all the fields' values and types of a given row from any dataset.
  * <p> Only the following types are handled: 
  * BOOLEAN, UNSIGNED, INTEGER, DECIMAL, REAL, STRING AND QSTRING.
  * <p> Note: This implementation does not handle compound datatypes having child datasets
  * or complex record structures.
  *
  * @param r: any row.
  *   <p>The row from which to extract the fields' values
  *
  * @return fieldsValues: DATASET(FieldValue).
  *   <p> the fields' values
  */
EXPORT GetRowValuesAndTypes(r) := FUNCTIONMACRO
  IMPORT ML_Core.Preprocessing;

  #EXPORTXML(rMetaInfo, r)
  #UNIQUENAME(temp)
  #SET(temp, 'DATASET([')
  #FOR(rMetaInfo)
    #FOR(field)
      #IF(%'{@isEnd}'% = '' AND %'{@isRecord}'% = '' AND %'{@isDataset}'% = '')
        #APPEND(temp, '{\'' + %'@type'% + '\',' + #TEXT(r) + '.' + %'@name'% + '},')
      #END
    #END
  #END
  
  //temp := %'temp'%;
  //removing the semi-colon of last entry before specifying the result's type
  #UNIQUENAME(Result)
  %Result% := %'temp'%[1..LENGTH(%'temp'%)-1] + '], Preprocessing.Utils.DatasetComparator.Types.FieldTypeAndValue)';
  RETURN #EXPAND(%Result%);
ENDMACRO;