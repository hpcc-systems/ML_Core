/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
  * For categorical features within a dataset, 
  * this module creates new binary and numeric features. The new binary features only takes a value of 0 or 1 indicating the true value of the category.
  *
  * @param baseData: DATASET(NumericField), default = DATASET([], NumericField).
  *   <p> Data from which categories are extracted for encoding/decoding.
  *
  * @param featureIds: SET OF UNSIGNED, default = [].
  *   <p> The set of indexes (numbers) of categorical features.
  *
  * @return key: DATASET(KeyLayout), default = DATASET([], KeyLayout)
  *   <p> A dataset storing, for each feature in baseData, its index (number), 
  *   its start index in the encoded data, and its category set.                          
  */

IMPORT $.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;
KeyLayout := $.Types.OneHotEncoder.KeyLayout;


EXPORT OneHotEncoder(DATASET(NumericField) baseData = DATASET([], NumericField), 
                     SET OF UNSIGNED featureIds = [], 
                     DATASET(KeyLayout) key = DATASET([], KeyLayout)) := MODULE
  
  SHARED numberLayout := $.Types.numberLayout;
  SHARED valueLayout := $.Types.valueLayout;
  SHARED t_fieldNumber := ML_Core.Types.t_FieldNumber;

  /**
    * Validates input.
    * <p> Input is valid if either baseData and featureIds are provided or key is provided.
    *
    * @return True when input is valid, False otherwise.
    */
  EXPORT isValidInput() := FUNCTION
    Result := IF(EXISTS(key) OR (EXISTS(baseData) AND EXISTS(featureIds)), True, False);
    RETURN Result;
  END;

  /**
    * Extracts from base data, the number and categories of each feature in featureIds.
    *
    * @return partialKey: DATASET(KeyLayout).
    *   <p> A dataset storing, for each feature in baseData, its index (number) and its category 
    *   set.
    */
  EXPORT GetNumberAndCategories() := FUNCTION
    IMPORT STD;

    categoricalDS := baseData(number IN featureIDs);
    categorical0 := TABLE(categoricalDS, {number, value}, number, value);
    init := GROUP(SORT(categorical0, number), number);
    categorical := ROLLUP(init,
                         GROUP,
                         TRANSFORM(KeyLayout,
                         SELF.number := LEFT.number,
                         SELF.startNumWhenEncoded := 0,
                         SELF.categories := DATASET(SET(ROWS(LEFT), value),
                         valueLayout)));
    nonCategorical := TABLE(baseData(number NOT IN featureIDs),
                           {number,
                           UNSIGNED4 startNumWhenEncoded := 0,
                           Categories := DATASET([], valueLayout)},
                           number);
    result := categorical + nonCategorical;
    RETURN SORT(Result, number);
  END;

  /**
    * Computes the key using basedData and featureIds.
    *
    * @return keyFromData: DATASET(KeyLayout)
    *   <p> A dataset storing, for each feature in baseData, its index (number), 
    *   its start index in the encoded data, and its category set. 
    */
  EXPORT GetKeyFromData() := FUNCTION
    //iterate over each consecutive pair of features to compute the start number in encoded data
    KeyLayout computeStartNum (KeyLayout L, KeyLayout R) := TRANSFORM
      //if there are categories, then the gap is the number of categories. Otherwise, it is 1.
      gap := IF(EXISTS(L.categories), COUNT(L.categories), 1);
      //when L is empty (initially), we set startNumWhenEncoded to 1.
      SELF.startNumWhenEncoded := IF(L.startNumWhenEncoded = 0, 1, L.startNumWhenEncoded + gap);
      SELF := R;
    END;
    
    //we first get the number and categories and then iterate through that result to get the start 
    //numbers in encoded data
    partialKey := GetNumberAndCategories();
    Result := ITERATE(partialKey, computeStartNum(LEFT, RIGHT));        
    RETURN Result;
  END;
  
  //the key used by encode and decode functions
  errorMsg := 'OneHotEncoder: must pass either key or baseData and featureIds!';
  SHARED innerKey := IF(isValidInput(), 
                           IF(EXISTS(key), key, GetKeyFromData()), 
                           ERROR(KeyLayout, 1, errorMsg));
  
  //the FeatureIds used by encode and decode functions
  SHARED innerFeatureIds := IF (EXISTS(key), SET(key(EXISTS(categories)), number), featureIds);

  /**
    * Extracts, from base data, the index, start number in encoded data and categories of each
    * feature in baseData or returns the key if it was provided. If a feature is not included in
    * featureIds, its categories will be empty.
    *
    * @return key: DATASET(KeyLayout)
    *   <p> A dataset storing, for each feature in baseData, its index (number), 
    *   its start index in the encoded data, and its category set.
    */
  EXPORT GetKey() := FUNCTION              
    RETURN innerKey;
  END;

  /**
    * oneHotEncodes a single row (value of a feature).
    *
    * @param row_: NumericField.
    *   <p> The row to oneHotEncode.
    *
    * @return the row's oneHotCode: DATASET(NumericField).
    *   <p> The oneHotCode of the row.
    */
  SHARED EncodeRow(NumericField row_) := FUNCTION 
    startNumber := innerKey(number = row_.number)[1].startNumWhenEncoded;
    
    //assign 1 if row value matches the category, 0 otherwise.
    NumericField XF(valueLayout L, t_FieldNumber cnt) := TRANSFORM
      SELF.wi := row_.wi;
      SELF.id := row_.id;
      SELF.number := startNumber + cnt - 1;
      SELF.value := IF(L.value = row_.value, 1, 0);
    END;
    
    //feature's categories for the row
    categories := innerKey(number = row_.number)[1].categories;
    Result := PROJECT(categories, XF(LEFT, COUNTER));
    RETURN Result;
  END;
  
  //record for storing a oneHotCode.
  SHARED OneHotCode := RECORD
    DATASET(NumericField) value;
  END;

  /**
    * OneHotEncodes a given dataset.
    *
    * @param dataToEncode: DATASET(NumericField).
    *   <p> The data to encode.
    *
    * @return encodedData: DATASET(NumericField).
    *   <p> The oneHotEncoded data.
    */
  EXPORT Encode (DATASET(NumericField) dataToEncode) := FUNCTION    
    //convert each row in its oneHotCode
    OneHotCode convert (NumericField L) := TRANSFORM
      numIfNonCategorical := innerKey(number = L.number)[1].startNumWhenEncoded;
      SELF.value := IF(L.number IN innerFeatureIds, 
                       EncodeRow(L), 
                       DATASET([{L.wi, L.id, numIfNonCategorical, L.value}], NumericField));
    END;

    oneHotCodes := PROJECT(dataToEncode, convert(LEFT));
    
    //Get all oneHotCodes as a single dataset of NumericField   
    NumericField XF(NumericField R) := TRANSFORM
      SELF := R;
    END;

    Result := NORMALIZE(oneHotCodes, LEFT.value, XF(RIGHT));
    RETURN Result;
  END;

  /**
    * Build a table mapping all field ids (number field) in onehotencoded data 
    * to the field id to which they correspond to in the original data.
    *
    * @param numbersInEncodedData: 
    *   <p> The unique numbers (number field) in the encoded data.
    *
    * @return mapping: DATASET(numberMapping).
    *   <p> The mapping between the numbers.
    */
  EXPORT GetNumberMapping(DATASET(numberLayout) numbersInEncodedData) := FUNCTION    
    numberMapping := $.Types.OneHotEncoder.numberMapping;

    startNums := SET(innerKey, startNumWhenEncoded);

    //setup result template using innerkey, setting all unknowns to 0
    numberMapping setup (numberLayout L) := TRANSFORM
      SELF.numberWhenEncoded := L.number;
      SELF.numberWhenDecoded := IF(L.number IN startNums,
                                   innerKey(startNumWhenEncoded = L.number)[1].number,
                                   0);
    END;
    
    resultTemplate := PROJECT(numbersInEncodedData, setup(LEFT));

    //replace all zeros by the numberWhenDecoded of previous
    numberMapping replaceZeros (numberMapping L, numberMapping R) := TRANSFORM
      SELF.numberWhenDecoded := IF(L.numberWhenEncoded <> 0 AND R.numberWhenDecoded = 0, 
                                   L.numberWhenDecoded, 
                                   R.numberWhenDecoded);
      SELF := R;
    END;

    Result := ITERATE(resultTemplate, replaceZeros(LEFT, RIGHT));
    RETURN Result;
  END;

  /**
   * Decodes a oneHotEncoded data.
   *
   * @param dataToDecode: DATASET(NumericField).
   *   <p> The data to decode.
   *
   * @return decodedData: DATASET(NumericField).
   *   <p> The decoded data.
   */
  EXPORT Decode (DATASET(NumericField) dataToDecode) := FUNCTION
    //map numbers in encoded data to numbers in decoded data
    numbersInData := SET(dataToDecode(id = 1), number);
    numberMapping := GetNumberMapping(DATASET(numbersInData, numberLayout));

    //append to each row in dataToDecode its number when decoded
    ExtendedNumericField := RECORD
      NumericField nf;
      t_fieldNumber numberWhenDecoded;
    END;

    ExtendedNumericField extend(NumericField L) := TRANSFORM
      SELF.numberWhenDecoded := numberMapping(numberWhenEncoded = L.number)[1].numberWhenDecoded;
      SELF.nf := L;
    END;

    extendedData := PROJECT(dataToDecode, extend(LEFT));

    //rollup grouping by wi, id and numberWhenDecoded
    NumericField convert (ExtendedNumericField top, DATASET(ExtendedNumericField) grp) := TRANSFORM
      SELF.wi := top.nf.wi;
      SELF.id := top.nf.id;
      SELF.number := top.numberWhenDecoded;
      
      //idx in categories = number where value is 1 - number of first + 1
      idx := grp(nf.value = 1)[1].nf.number - top.nf.number + 1;
      currentKey := innerKey(startNumWhenEncoded = top.nf.number)[1];
      valueIfcategorical := currentKey.categories[idx].value;
      isCategorical := currentKey.number IN innerFeatureIds;
      isUnknown := COUNT(grp(nf.value <> 0)) = 0;
      SELF.value := IF(isCategorical, 
                       IF(isUnknown, -1, valueIfcategorical),
                       top.nf.value);
    END;
    
    groupedData := GROUP(extendedData, nf.wi, nf.id, numberWhenDecoded);
    Result := ROLLUP(groupedData, GROUP, convert(LEFT, ROWS(LEFT)));
    RETURN Result;
  END;
END;
