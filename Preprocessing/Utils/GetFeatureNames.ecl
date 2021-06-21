/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Extracts the feature names from some dataset.
  * <p> Note: complex record structures with child datasets are not handled.
  *
  * @param dta: any dataset.
  *   <p> Dataset from which to extract the feature names
  *
  * @return featureNames: SET OF STRING
  *   <p> A set of string holding the feature names.
  */
EXPORT GetFeatureNames(dta) := FUNCTIONMACRO
  #EXPORTXML(dtaMetaInfo, RECORDOF(dta))
  #UNIQUENAME(featureNames)
  #SET(featureNames, '[')
  #FOR(dtaMetaInfo)
    #FOR(field)
      #APPEND(featureNames, '\'' + %'{@label}'% + '\',')
    #END
  #END

  temp := %'featureNames'%;
  //removing last comma and adding closing bracket
  temp2 := temp[1..LENGTH(temp)-1] + ']';
  result := #EXPAND(temp2);
  RETURN result;
ENDMACRO;