/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Builds a lookup table that maps each category to a unique number.
  * Each category is assigned its index in the category set.
  *
  * @param featureName: STRING.
  *   <p> The name of the feature.
  *
  * @param unmappedCategories: SET OF STRING.
  *   <p> The feature's unmapped categories.
  *
  * @return categoriesMapping: ROW(MappingLayout).
  *   <p> A row the feature name mapped to its categories and each category
  *   mapped to its value.
  */
IMPORT $.Types;

EXPORT MapAFeatureCategories(STRING featureName, SET OF STRING unmappedCategories) := FUNCTION
  Category := Types.Category;
  mappingLayout := Types.mappingLayout;
  labelLayout := Types.LabelLayout;

  Category assignValue (labelLayout L, UNSIGNED cnt) := TRANSFORM
    SELF.categoryName := L.label;
    SELF.value := cnt - 1;
  END;
  CategoriesDS := DATASET(unmappedCategories, labelLayout);
  temp := PROJECT(CategoriesDS, assignValue(LEFT, COUNTER));
  Result := DATASET([{featureName, temp}], mappingLayout);
  RETURN Result;
END;