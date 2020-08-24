/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as ML_C;
IMPORT Preprocessing.Utils.Types;
IMPORT Preprocessing.PTypes;

KeyRec := PTypes.OneHotEncoder.KeyRec;
NumericField := ML_C.Types.NumericField;
valueRec := Types.valueRec;
numberRec := Types.numberRec;
OneHotCodeRec := RECORD
  DATASET(NumericField) oneHotCode;
END;

/**
 * Allows to handle categorical features with no ordering relationship
 *
 * <p> Given a categorical feature, it creates new binary features 
 * indicating the presence of each Category of the feature. 
 * The reverse operation can also be done.
 *
 * @param baseData: DATASET(NumericField), default = DATASET([], NumericField)
 *   The data on which the encoding and decoding will be based
 *
 * @param featureList: SET OF UNSIGNED, default = []
 *   The list of indexes of each feature to be considered for encoding and decoding. 
 *   Each index represents the position of the feature in the ordered list of features.
 *
 * @return key: DATASET(KeyRec), default = DATASET([], KeyRec)
 *   A dataset holding, for each feature, its index (number), 
 *   its start index in the encoded data, and its category set.
 *
 * @see LabelEncoder                            
 */
EXPORT OneHotEncoder(DATASET(NumericField) baseData = DATASET([], NumericField), 
                     SET OF UNSIGNED featureList = [], 
                     DATASET(KeyRec) key = DATASET([], KeyRec)) := MODULE
  
  /**
   * Computes the key using some dataset and a valid featureList
   *
   * @param ds: DATASET(NumericField)
   *   The dataset from which the categories are extracted
   *
   * @param validFeatureList: DATASET(numberRec)
   *   The categorical features' indexes which do exist in ds
   *
   * @return key
   */
  SHARED GetKeyFromData(DATASET(NumericField) ds, 
                        DATASET(numberRec) validFeatureList) := FUNCTION

    KeyRec GetCategories(numberRec featureNum) := TRANSFORM
      SELF.number := featureNum.val;
      valueSET := SET(ds(number = featureNum.val), value);
      valueDS  := SORT(DATASET(valueSET, valueRec), val);
      isCategorical := COUNT(validFeatureList(val = featureNum.val)) <> 0;
      SELF.categories := IF(isCategorical, DEDUP(valueDS), DATASET([], valueRec));
      SELF.startNumInEncData := 0;
    END;
    
    featureNumbers := DATASET(SET(ds(id = 1), number), numberRec);
    tempResult := PROJECT(featureNumbers, GetCategories(LEFT));

    KeyRec GetStartNumInEncData (KeyRec L, KeyRec R) := TRANSFORM
      startNumOfLeft := IF(L.startNumInEncData = 0, 1, L.startNumInEncData);
      gap := IF(L.startNumInEncData <> 0 AND COUNT(L.categories) = 0, 1, COUNT(L.categories));
      SELF.startNumInEncData := startNumOfLeft + gap;
      SELF := R;
    END;

    result := ITERATE(tempResult, GetStartNumInEncData(LEFT, RIGHT));        
    RETURN result;
  END;

  /**
   * Extracts, from base data, information for each feature whose index was provided.
   * Or reuses the key if it was provided
   *
   * @return key
   */
  EXPORT GetKey() := FUNCTION
    featureListDS := DATASET(featureList, numberRec);
    validFeatureList := featureListDS(val IN SET(baseData, number));

    validationMsg := IF(COUNT(key) = 0, 
                        IF(COUNT(baseData) <> 0,  
                           IF(COUNT(validFeatureList) <> 0, 
                              'validData', 
                              'Feature List is Empty'),
                            'Base data is Empty'), 
                        'validKey');
    
    Result := IF(validationMsg = 'validData', 
                 GetKeyFromData(baseData, validFeatureList), 
                 IF(validationMsg = 'validKey', key, ERROR(keyRec, validationMsg)));
                 
    RETURN Result;
  END;
  
  /**
   * oneHotEncodes a single row
   *
   * @param row_: NumericField
   *   the row to oneHotEncode
   *
   * @param key: DATASET(KeyRec)
   *   the oneHotEncoder key
   *
   * @return the row's oneHotCode
   */
  SHARED EncodeRow(NumericField row_, DATASET(KeyRec) key) := FUNCTION 
    startNum := key(number = row_.number)[1].startNumInEncData;

    NumericField XF(valueRec L, ML_C.Types.t_FieldNumber cnt) := TRANSFORM
      SELF.wi := row_.wi;
      SELF.id := row_.id;
      SELF.number := startNum + cnt - 1;
      SELF.value := IF(L.val = row_.value, 1, 0);
    END;
    
    categories := key(number = row_.number)[1].categories;
    Result := PROJECT(categories, XF(LEFT, COUNTER));
    RETURN Result;
  END;
  
  /**
   * OneHotEncodes a given dataset
   *
   * @param dataToEncode: DATASET(NumericField)
   *   the data to encode
   *
   * @return the encoded data
   */
  EXPORT Encode (DATASET(NumericField) dataToEncode) := FUNCTION
    key_ := IF (COUNT(key) <> 0, key, GetKey());
    featList := IF (COUNT(key) <> 0, SET(key(COUNT(categories) <> 0), number), featureList);

    OneHotCodeRec := RECORD
      DATASET(NumericField) oneHotCode;
    END;

    OneHotCodeRec convertRow (NumericField L) := TRANSFORM
      numIfNonCategorical := key_(number = L.number)[1].startNumInEncData;
      SELF.oneHotCode := IF(L.number IN featList, 
                            EncodeRow(L, key_), 
                            DATASET([{L.wi, L.id, numIfNonCategorical, L.value}], NumericField));
    END;

    oneHotCodes := PROJECT(dataToEncode, convertRow(LEFT));

    OneHotCodeRec XF (OneHotCodeRec L, OneHotCodeRec R) := TRANSFORM
      SELF.oneHotCode := L.oneHotCode + R.OneHotCode;
    END;
    
    Result := ITERATE(oneHotCodes, XF(LEFT, RIGHT));    
    RETURN Result[COUNT(Result)].oneHotCode;
  END;
  
  /**
   * convert each row in a numericField dataset
   * into a NumericField dataset of one element.
   *
   * @param dta: DATASET(NumericField)
   *   the numericField dataset to convert
   *
   * @return the converted dataset
   */
  SHARED convertRowsToDS (DATASET(NumericField) dta) := FUNCTION    
    OneHotCodeRec XF (NumericField L) := TRANSFORM
      SELF.oneHotCode := DATASET([L], NumericField);
    END;

    Result := PROJECT(dta, XF(LEFT));
    RETURN Result;
  END;
  
  /**
   * Determines which rows form a oneHotCode
   *
   * @param dta: DATASET(OneHotCodeRec)
   *   the data from which the oneHotCodes are determined.
   *
   * @param key_: DATASET(KeyRec)
   *   the oneHotCncoder key.
   *
   * @return the grouped OneHotCodes
   */
  SHARED GroupOneHotCodes (DATASET(OneHotCodeRec) dta, DATASET(KeyRec) key_) := FUNCTION
    startNums := SET(key_, startNumInEncData);

    OneHotCodeRec XF (OneHotCodeRec L, OneHotCodeRec R) := TRANSFORM
      isInStartNums := R.oneHotCode[1].number IN startNums;
      SELF.oneHotCode := IF(isInStartNums, R.oneHotCode, L.oneHotCode + R.oneHotCode);
    END;
    temp := ITERATE(dta, XF(LEFT, RIGHT));
    
    categories := key_(startNumInEncData = temp.oneHotCode[1].number)[1].categories;
    Result := temp(COUNT(oneHotCode) <> 1 OR COUNT(categories) = 0);
    RETURN Result; 
  END;

  /**
   * Decodes a oneHotEncoded data
   *
   * @param dataToDecode: DATASET(NumericField)
   *   the data to decode
   *
   * @return the decoded data
   */
  EXPORT Decode (DATASET(NumericField) dataToDecode) := FUNCTION
    key_ := IF (COUNT(key) <> 0, key, GetKey());
    convertedRows := convertRowsToDs(dataToDecode);
    groupedRows := groupOneHotCodes(convertedRows, key_);

    featList := IF (COUNT(key) <> 0, SET(key(COUNT(categories) <> 0), number), featureList);
    NumericField XF (OneHotCodeRec L) := TRANSFORM
      SELF.wi := L.oneHotCode[1].wi;
      SELF.id := L.oneHotCode[1].id;
      currentKey := key_(startNumInEncData = L.oneHotCode[1].number)[1];
      SELF.number := currentKey.number;
      idx := L.oneHotCode(value = 1)[1].number - L.oneHotCode[1].number + 1;
      valueIfcategorical := currentKey.categories[idx].val;
      valueIfNotCategorical := L.oneHotCode[1].value;
      isCategorical := currentKey.number IN featList;
      isUnknown := COUNT(L.oneHotCode(value <> 0)) = 0;
      SELF.value := IF(isCategorical, 
                       IF(isUnknown, -1, valueIfcategorical),
                       valueIfNotCategorical);
    END;

    Result := PROJECT(groupedRows, XF(LEFT));
    RETURN Result;
  END;
END;


 