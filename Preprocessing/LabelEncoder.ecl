/*###################################################################################
## HPCC SYSTEMS software Copyright (C) 2020 - 2021 HPCC Systems.  All rights reserved.
##################################################################################### */

/**
 * Allows to convert categorical values into numeric format.
 *
 * For example: use LabelEncoder to convert below raw data:
 * raw := DATASET([{'apple'},
 *                 {'grape'}], {STRING fruit});
 * The result is as following:
 * convertedDs := DATASET([{0},
 *                         {1}], {INTEGER fruit});
 *
 * Curently does not support Myriad interface
 */
EXPORT LabelEncoder := MODULE
  /**
   * Builds a mapping between feature names and categories.
   *
   * @param dataForUndefinedCategories: any record-oriented dataset.
   *   <p>The data from which the categories are extracted
   *   if not predefined in the list of categorical features.
   *
   * @param partialKey: same record structure as the key (see below).
   *   <p> Mapping between feature names and categories.
   *   Some names are mapped to empty categories such that
   *   their categories could be extracted from dataForUndefinedCategories.
   *
   * @return key: DATASET(KeyLayout)
   *   <p>The full mapping between categorical feature names and their categories.
   *   Its record structure has the following format:
   *   <p>
   *   <pre>
   *   KeyLayout := RECORD
   *     SET OF STRING <name of categorical feature 1>;
   *     SET OF STRING <name of categorical feature 2>;
   *     ...
   *     SET OF STRING <name of categorical feature n>;
   *   END;
   *   </pre>
   */
  EXPORT GetKey(dataForUndefinedCategories, partialKey) := FUNCTIONMACRO
    IMPORT Preprocessing.Utils as U;

    KeyLayout := RECORDOF(partialKey);
    #EXPORTXML(KeyMetaInfo, partialKey)
    dta := #TEXT(dataForUndefinedCategories);

    KeyLayout completeKey(KeyLayout L) := TRANSFORM
      #FOR(KeyMetaInfo)
        #FOR(field)
          #EXPAND('SELF.' + %'@label'% + ' := IF(EXISTS(L.' + %'@label'% + '), '
                                            + 'L.' + %'@label'% + ','
                                            + 'U.GetCategories(' + dta + ',' + %'@label'% + '))');

        #END
      #END
    END;

    Result := PROJECT(partialKey, completeKey(LEFT));
    RETURN Result;
  ENDMACRO;


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
  EXPORT GetMapping(key) := FUNCTIONMACRO
    IMPORT Preprocessing.Utils.LabelEncoder;
    RETURN LabelEncoder.MapCategoriesToValues(key);
  ENDMACRO;


  /**
    * Replaces each categorical value in the data with its index in the key.
    * Every unknown category (not in the key) is replaced by -1.
    *
    * @param dataToEncode: any dataset.
    *   <p> The data to encode.
    *
    * @param key: DATASET(KeyLayout).
    *   <p> Mapping between feature names and their categories.
    *
    * @return encodedData: same record structure as dataToEncode
    *   with the datatype of all categorical features changed to INTEGER.
    *   <p> Data with categorical values replaced by numbers.
    */
  EXPORT Encode(dataToEncode, key) := FUNCTIONMACRO
    IMPORT Preprocessing.Utils;

    //build mapping between categories and values
    #UNIQUENAME(mapping)
    %mapping% := Utils.LabelEncoder.MapCategoriesToValues(key);

    //build final record structure
    featureNameSET := Utils.GetFeatureNames(key);

    #EXPORTXML(dataMetaInfo, RECORDOF(dataToEncode))
    EncodedDataLayout := RECORD
      #FOR(dataMetaInfo)
        #FOR(field)
          #IF(%'@label'% IN featureNameSET)
            #EXPAND('INTEGER ' + %'@label'%);
          #ELSE
            #EXPAND(%'@type'% + ' ' + %'@label'%);
          #END
        #END
      #END
    END;

    //replace categories by corresponding value
    #EXPORTXML(keyMetaInfo, RECORDOF(key))
    #UNIQUENAME(categories)
    #UNIQUENAME(category)
    EncodedDataLayout replace (RECORDOF(dataToEncode) L):= TRANSFORM
      #FOR(keyMetaInfo)
        #FOR(field)
          #SET(categories, %'mapping'% + '(featureName = \'' + %'@label'% + '\')[1].categories')
          #SET(category, %'categories'% + '(categoryName = (STRING)L.' + %'@label'% + ')')
          SELF.%@label% := IF(EXISTS(%category%), %category%[1].value, -1);
        #END
      #END
      SELF := L;
    END;

    result := PROJECT(dataToEncode, replace(LEFT));
    RETURN result;
  ENDMACRO;

  /**
    * Converts back the categorical values into their original labels.
    * Every -1 is replaced by an empty string.
    *
    * @param dataToDecode: any dataset.
    *   <p> The data to decode.
    *
    * @param key: DATASET(KeyLayout).
    *   <p> Mapping between feature names and their categories.
    *
    * @return decodedData: same record structure as dataToDecode
    *   with the datatype of all categorical features changed to STRING.
    *   <p> Data with categorical values replaced by their original labels.
    */
  EXPORT Decode(dataToDecode, encoderKey) := FUNCTIONMACRO
    IMPORT Preprocessing.Utils;

    //build mapping between categories and values
    #UNIQUENAME(mapping)
    %mapping% := Utils.LabelEncoder.MapCategoriesToValues(key);
    //build final record structure
    featureNameSET := Utils.GetFeatureNames(key);

    #EXPORTXML(dataMetaInfo, RECORDOF(dataToDecode))
    DecodedDataLayout := RECORD
      #FOR(dataMetaInfo)
        #FOR(field)
          #IF(%'@label'% IN featureNameSET)
            #EXPAND('STRING ' + %'@label'%);
          #ELSE
            #EXPAND(%'@type'% + ' ' + %'@label'%);
          #END
        #END
      #END
    END;

    //replace values by original labels
    #EXPORTXML(keyMetaInfo, RECORDOF(key))
    #UNIQUENAME(categories)
    #UNIQUENAME(category)
    DecodedDataLayout replace (RECORDOF(dataToDecode) L):= TRANSFORM
      #FOR(keyMetaInfo)
        #FOR(field)
          #SET(categories, %'mapping'% + '(featureName = \'' + %'@label'% + '\')[1].categories')
          #SET(category, %'categories'% + '(value = L.' + %'@label'% + ')')
          SELF.%@label% := %category%[1].categoryName;
        #END
      #END
      SELF := L;
    END;

    result := PROJECT(dataToDecode, replace(LEFT));
    RETURN result;
  ENDMACRO;
END;