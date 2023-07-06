/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Builds a lookup table that maps each category of a feature to a unique number.
  * Each category is assigned its index in the category set.
  *
  * @param key: DATASET(KeyLayout).
  *   <p> Mapping between feature names and categories.
  *
  * @return categoriesMapping: DATASET(MappingLayout).
  *   <p> A table with each feature name mapped to its categories and each category
  *   mapped to its value.
  *
  *   <pre>
  *   //record mapping a category to its value.
  *   Category := RECORD
  *     STRING categoryName;
  *     INTEGER value;
  *   END;
  *
  *   //record mapping feature names to their categories.
  *   MappingLayout := RECORD
  *     STRING featureName;
  *     DATASET(Category) categories;
  *   END;
  *   </pre>
  */
EXPORT MapCategoriesToValues(key) := FUNCTIONMACRO
  IMPORT ML_Core.Preprocessing.Utils;
  IMPORT ML_Core.Preprocessing.Utils.LabelEncoder as E;

  //looping through each feature and getting the mapping of its categories.
  featureNames := Utils.GetFeatureNames(key);
  result0 := DATASET([], Utils.LabelEncoder.Types.MappingLayout);

  #DECLARE(cnt)
  #SET(cnt, 1)
  #DECLARE (unmappedCategories)
  #DECLARE(fName)
  #LOOP
    #IF (%cnt% > COUNT(featureNames))
      #BREAK
    #ELSE
      #SET (unmappedCategories, #TEXT(key) + '.' + featureNames[%cnt%]);
      #SET(fName, '\'' + featureNames[%cnt%] + '\'');
      #EXPAND('result' + %'cnt'% + ' := result' + (%cnt%-1) +
              ' + E.MapAFeatureCategories(' + %'fName'% + ',' + %'unmappedCategories'% + ')');
    #SET (cnt, %cnt% + 1)
    #END
  #END
  resultId := 'result' + (%cnt% - 1);
  Result := #EXPAND(resultId);
  RETURN Result;
ENDMACRO;