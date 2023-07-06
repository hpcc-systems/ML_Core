/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as ML_Core;
IMPORT $.Types;
NumericField := ML_Core.Types.NumericField;
l_cFeatures := Types.OneHotEncoder.cFeatures;

/**
  * OneHotEncoder
  *
  * OneHotEncode is used to convert each of the designated categorical features to a binary
  * (absent/present) value (i.e.oneHot) for use by algorithms that don't directly support
  * categorical values. Also can convert back from oneHot encoding to numerical category. Each
  * categorical field will produce additional features according to its cardinality.
  * For example, if there are four possible categories, then the original feature will be replaced
  * by four binary features.
  *
  * Supports Myriad Interface.
  *
  * @param ds  dataset to be encoded.
  * @param categoricalFeatures categorical feature IDs for each work item.
  *                            e.g. to encoded field number 3 for work item 1, below
  *                            categoricalFeatures can be used:
  *                            DATASET([{1, 3}], l_cFeatures)
  *
  */
EXPORT OneHotEncoder(DATASET(NumericField) ds = DATASET([], NumericField),
                     DATASET(l_cFeatures) categoricalFeatures = DATASET([], l_cFeatures)) := MODULE
  /**
    * Validates input.
    * @return True when input is valid, False otherwise.
    */
  EXPORT isValidInput() := FUNCTION
    Result := IF(EXISTS(categoricalFeatures) AND (EXISTS(ds)), True, False);
    RETURN Result;
  END;
  SHARED categoricalDS := JOIN(ds, categoricalFeatures,
                               LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                               TRANSFORM(RECORDOF(LEFT), SELF := LEFT), LOOKUP);
  SHARED nonCategoricalDS := ds-categoricalDS;
  SHARED nonCategories := TABLE(nonCategoricalDS, {wi, number, value}, wi, number);
  SHARED categories := TABLE(categoricalDS, {wi, number, value}, wi, number, value);
  SHARED mappings := PROJECT(GROUP(SORT(nonCategories + categories, wi, number, value), wi),
                            TRANSFORM({RECORDOF(LEFT), UNSIGNED4 newNum},
                                      SELF.newNum := COUNTER, SELF := LEFT));
  SHARED errorMsg := 'Invalid input';
  // Computes the mapping between the orignal feature id and
  // the corresponding encoded feature id using input data and featureIds.
  EXPORT getMappings := IF(isValidInput(),
                          GROUP(mappings),
                          ERROR(RECORDOF(mappings), 1, errorMsg));
  SHARED noncat_mappings :=JOIN(mappings, nonCategories,
                                LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                                TRANSFORM(RECORDOF(LEFT), SELF := LEFT));
  SHARED cat_mappings := mappings - noncat_mappings;
  SHARED newCatDS := JOIN(categoricalDS, mappings,
                          LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                          TRANSFORM(RECORDOF(LEFT),
                                    SELF.number := RIGHT.newnum,
                                    SELF.value := IF(LEFT.value = RIGHT.value, 1, 0),
                                    SELF := LEFT), MANY);
  SHARED newNonCatDS := JOIN(nonCategoricalDS, mappings,
                            LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                            TRANSFORM(RECORDOF(LEFT),
                                      SELF.number := RIGHT.newNum,
                                      SELF := LEFT));
  // Encoded data
  EXPORT encode := newNonCatDS + newCatDS;
  /**
    * Revert the encoded data to its original form
    * @param encodedDS encoded data
    * @return decoded  decoded data
    */
  EXPORT decode(DATASET(NumericField) encodedDS) := FUNCTION
          decodedCat := JOIN(encodedDS(value <> 0), cat_mappings,
                             LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.newNum,
                             TRANSFORM(RECORDOF(LEFT),
                                      SELF.number := RIGHT.number,
                                      SELF.value := RIGHT.value,
                                      SELF := LEFT),lookup);
          decodedNonCat := JOIN(encodedDS, noncat_mappings,
                               LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.newNum,
                               TRANSFORM(RECORDOF(LEFT),
                               SELF.number := RIGHT.number,
                               SELF := LEFT),lookup);
          decoded := SORT(decodedcat + decodedNoncat, wi, id, number);
          RETURN decoded;
  END;
END;