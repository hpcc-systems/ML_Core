/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Allows to convert both ordinal and nominal features into numbers
 * by assigning them values in the range [0 .. #OfCategories - 1]. 
 *
 * @see OneHotEncoder                                     
 */
EXPORT LabelEncoder := MODULE
  /**
   * Extracts, from the base data, 
   * unique values for each feature in the feature list. 
   *
   * @param baseData
   *   The data from which the unique values are extracted.
   *
   * @param featureList                  
   *   The list of features and their respective categories. 
   *   If for a feature, the category set is empty, the categories will be extracted from baseData.
   *             
   * @return key
   *   the categories for each feature in featureList
   */
  EXPORT GetKey(baseData, featureList) := FUNCTIONMACRO
    IMPORT Preprocessing.LabelEncoder;
    IMPORT Preprocessing.Utils.Types;
    
    FeatureListRec := RECORDOF(featureList);
    #EXPORTXML(featureListFields, FeatureListRec)

    #DECLARE(KeyLayout)
    #SET(keyLayout, 'RECORD\n')
    #FOR(featureListFields)
      #FOR(field)
        #IF(%'@label'% IN LabelEncoder.GetFeatureNames(baseData))
          #APPEND(keyLayout, %'@type'% + ' ' + %'@label'% + ';\n'); 
        #ELSE
          #WARNING(%'@label'% + ' is not a valid feature name!');   
        #END
      #END
    #END
    #APPEND(keyLayout, 'END;')
    EncoderKeyRec := #EXPAND(%'keyLayout'%);
    
    #EXPORTXML(encoderKeyFields, EncoderKeyRec)
    EncoderKeyRec buildEncoderKey(FeatureListRec L) := TRANSFORM
      #FOR(encoderKeyFields)
        #FOR(field)
          #EXPAND('SELF.' + %'@label'% + ' := IF(COUNT(L.' + %'@label'% + ') = 0,' 
                                                 + 'LabelEncoder.GetUniqueValues(' + #TEXT(baseData) + ', ' + %'@label'% + '), ' 
                                                 + 'L.'+ %'@label'% + ')');
          
        #END
      #END
    END;

    encoderKey := PROJECT(featureList, buildEncoderKey(LEFT));
    RETURN encoderKey;
  ENDMACRO;

  /**
   * Map values to each feature's categories in encoder key
   *
   * @param the encoder key       
   *  the categories by feature
   *
   * @return the mapping
   */
  EXPORT GetMapping(encoderKey) := FUNCTIONMACRO
    IMPORT Preprocessing.LabelEncoder;
    IMPORT Preprocessing.PTypes;
  
    mappingRec := PTypes.LabelEncoder.mappingRec;   
    
    featureNames := LabelEncoder.GetFeatureNames(encoderKey);
    result0 := DATASET([], mappingRec);

    #DECLARE(idx)
    #SET(idx, 1)
    #DECLARE (setOfCategories)
    #SET (setOfCategories, '')
    #LOOP
      #IF (%idx% > COUNT(featureNames))
        #BREAK
      #ELSE
        #SET (setOfCategories, #TEXT(encoderKey) + '[1].' + featureNames[%idx%]);
        #EXPAND('result' + %'idx'% + ' := result' + (%idx%-1) + 
                ' +  LabelEncoder.GetMappingForOneFeature(\'' + featureNames[%idx%] + '\',' + %'setOfCategories'% + ')');
      #SET (idx, %idx% + 1)
      #END
    #END
    
    resultId := 'result' + (%idx% - 1);
    Result := #EXPAND(resultId);
    RETURN Result;
  ENDMACRO;  
  
  /**
   * For each feature in the encoder key, this function converts the values into unique numbers
   *
   * @param dataToEncode          
   * 
   * @param encoderKey
   *
   * @return the encoded data
   */
  EXPORT Encode(dataToEncode, encoderKey) := FUNCTIONMACRO
    IMPORT Preprocessing.LabelEncoder;

    featureNameSET := LabelEncoder.GetFeatureNames(encoderKey);
    #UNIQUENAME(mapping)
    %mapping% := LabelEncoder.GetMapping(encoderKey);
    
    isCategorical(STRING fname) := fname IN featureNameSET;

    #EXPORTXML(dataFields, RECORDOF(dataToEncode))
    EncodedDataRec := RECORD
      #FOR(dataFields)
        #FOR(field)
          #IF(isCategorical(%'@label'%))
            #EXPAND('INTEGER ' + %'@label'%);
          #ELSE
            #EXPAND(%'@type'% + ' ' + %'@label'%);
          #END        
        #END
      #END
    END;

    #EXPORTXML(encoderKeyFields, RECORDOF(encoderKey))
    #UNIQUENAME(currentCategory)
    EncodedDataRec encodeValues (RECORDOF(dataToEncode) currentRow):= TRANSFORM      
      #FOR(encoderKeyFields)
        #FOR(field)
          SELF.%@label% := IF(COUNT(%mapping%(featureName = %'@label'%)[1].categories(categoryName = (STRING)currentRow.%@label%)) = 0,
                              -1,
                              %mapping%(featureName = %'@label'%)[1].categories(categoryName = (STRING)currentRow.%@label%)[1].value);        
        #END
      #END
      SELF := currentRow;
    END;

    result := PROJECT(dataToEncode, encodeValues(LEFT));
    RETURN result;
  ENDMACRO;

  /**
   * For each feature in the encoder key, 
   * this function converts back the encoded values into their original values
   *
   * @param dataToDecode
   * 
   * @param encoderKey
   *
   * @return the decoded data
   */
  EXPORT Decode(dataToDecode, encoderKey) := FUNCTIONMACRO
    IMPORT Preprocessing.LabelEncoder;

    featureNameSET := LabelEncoder.GetFeatureNames(encoderKey);
    #UNIQUENAME(mapping)
    %mapping% := LabelEncoder.GetMapping(encoderKey);
    
    isCategorical(STRING fname) := fname IN featureNameSET;

    #EXPORTXML(dataFields, RECORDOF(dataToDecode))
    DecodedDataRec := RECORD
      #FOR(dataFields)
        #FOR(field)
          #IF(isCategorical(%'@label'%))
            #EXPAND('STRING ' + %'@label'%);
          #ELSE
            #EXPAND(%'@type'% + ' ' + %'@label'%);
          #END        
        #END
      #END
    END;

    DecodedDataRec encodeValues (RECORDOF(dataToDecode) currentRow):= TRANSFORM      
      #FOR(encoderKeyFields)
        #FOR(field)
          SELF.%@label% := %mapping%(featureName = %'@label'%)[1].categories(value = currentRow.%@label%)[1].categoryName;          
        #END
      #END
      SELF := currentRow;
    END;

    result := PROJECT(dataToDecode, encodeValues(LEFT));
    RETURN result;
  ENDMACRO;
  
  /**
   * Get unique values of a feature from a dataset
   * 
   * @param ds
   *   the dataset from which to get the unique values
   *
   * @param featureName
   *
   * @return the feature's unique values
   */
  EXPORT GetUniqueValues(ds, featureName) := FUNCTIONMACRO
    IMPORT Preprocessing.LabelEncoder;
    IMPORT Preprocessing.Utils.Types;
    
    values := (SET OF STRING) SET(ds, featureName);
    valueDS := DATASET(values, Types.StringRec);
    categories := DEDUP(SORT(valueDS, val));
    result := SET(categories, val);
    RETURN result;
  ENDMACRO;
  
  /**
   * Get the feature names from the encoder key
   * 
   * @param encoderKey
   *   the encoder key
   *
   * @return the feature names
   */
  EXPORT GetFeatureNames(encoderKey) := FUNCTIONMACRO
    #EXPORTXML(encoderKeyFields, RECORDOF(encoderKey))
    #DECLARE(featureNames)
    #SET(featureNames, '[')
    #FOR(encoderKeyFields)
      #FOR(field)
        #APPEND(featureNames, '\'' + %'{@label}'% + '\',')        
      #END
    #END

    list := %'featureNames'%;
    list2 := list[1..LENGTH(list)-1] + ']';
    result := #EXPAND(list2);
    RETURN result;
  ENDMACRO;
  
  /** 
   * assigns unique values to each category of a feature
   *
   * @param featureName
   *   the name of the feature
   *
   * @param setOfCategories
   *   the feature's categories
   *
   * @return the categories and their assigned values
   */
  EXPORT GetMappingForOneFeature(STRING featureName, SET OF STRING setOfCategories) := FUNCTION
    IMPORT Preprocessing.PTypes;
    
    categoryRec := PTypes.LabelEncoder.CategoryRec;
    mappingRec := PTypes.LabelEncoder.mappingRec;

    StringRec := RECORD
      STRING val;
    END;

    CategoryRec XF (StringRec L, UNSIGNED cnt) := TRANSFORM
      SELF.categoryName := L.val;
      SELF.value := cnt - 1;
    END;
    
    CategoriesDS := DATASET(setOfCategories, StringRec);
    categoriesValue := PROJECT(CategoriesDS, XF(LEFT, COUNTER));
    Result := DATASET([{featureName, categoriesValue}], mappingRec);
    RETURN Result;
  END;
END;