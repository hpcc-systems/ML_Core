/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Allows to extract all the categories of a feature from a given dataset.
  *
  * @param source: ANY.
  *   <p> the dataset from which to extract the categories.
  *
  * @param featureName: STRING.
  *   <p> the name of the feature for which to extract the categories.
  *
  * @return categories: SET OF STRING.
  *   <p> the feature's categories.
  */
EXPORT GetCategories(source, featureName) := FUNCTIONMACRO  
  values := (SET OF STRING) SET(source, featureName);
  valueDS := DATASET(values, {STRING val});
  categories := DEDUP(SORT(valueDS, val));
  Result := SET(categories, val);
  RETURN Result;
ENDMACRO;