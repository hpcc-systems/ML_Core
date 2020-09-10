/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
  * Allows to get the position, name, type and size
  * of each field in the record structure of a dataset.
  *
  * @param dta: any dataset.
  *   <p>The dataset from which to extract the fields' info
  *
  * @return fieldsInfo: DATASET(FieldInfo).
  *   <p> the fields' position, name, type and size.
  */
EXPORT GetFieldsInfo(dta) := FUNCTIONMACRO
  IMPORT Preprocessing;

  #EXPORTXML(dtaMetaInfo, dta)
  #UNIQUENAME(temp)
  #SET(temp, 'DATASET([')
  #FOR(dtaMetaInfo)
    #FOR(field)
      #IF(%'{@isEnd}'% = '')
        #APPEND(temp, '{' + %'@position'% + ',\'' + %'@name'% + '\',\'' 
                          + %'@type'% + '\',\'' + %'@size'% + '\'},')
      #END
    #END
  #END

  temp := %'temp'%;
  //removing the semi-colon of last entry before specifying the result's type
  #UNIQUENAME(Result)
  %Result% := temp[1..LENGTH(temp)-1] + '], Preprocessing.Utils.DatasetComparator.Types.FieldInfo)';
  RETURN #EXPAND(%Result%);
ENDMACRO;