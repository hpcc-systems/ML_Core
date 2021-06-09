/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;

Types := MLC.Preprocessing.Types;
KeyLayout := Types.MinMaxScaler.KeyLayout;
FeatureMinMax := Types.MinMaxScaler.FeatureMinMax;
NumericField := MLC.types.NumericField;
t_FieldReal := MLC.types.t_FieldReal;

/**
 * Scale the input data to a defined range [Min, Max].
 *
 * @param baseData: DATASET(NumericField), Default = DATASET([], NumericField).           
 *   <p> The data from which the minimums and maximums are determined.
 *
 * @param low: t_FieldReal, Default = 0.0                     
 *   <p> The minimum value of the normalized data.
 *
 * @param high: t_FieldReal, Default = 1.0                     
 *   <p> The maximum value of the normalized data.
 *
 * @param key: DATASET(KeyLayout), default = DATASET([], KeyRec).            
 *   <p> The key to be reused for scaling/unscaling.
 *
 * @see StandardScaler
 */
EXPORT MinMaxScaler (DATASET(NumericField) baseData = DATASET([], NumericField),
                     t_FieldReal lowBound = 0.0, t_FieldReal highBound = 1.0, 
                     DATASET(KeyLayout) key = DATASET([], KeyLayout)) := MODULE
  
  /**
   * Get mins and maxs for each feature in baseData.
   *
   * @return minAndMaxByFeature: DATASET(KeyLayout).
   */
  SHARED ComputeKey() := FUNCTION    
    //compute the mins and max for each feature
    minsAndMaxs :=  TABLE(baseData,
                         {featureID := number, minValue := MIN(GROUP, value),
                         maxValue := MAX(GROUP, value)},
                         wi, number, MERGE);

    //add lowBound and highBound to key
    Result := DATASET([{lowBound, highBound, minsAndMaxs}], KeyLayout);
    boundariesErrorMsg := 'lowBound must be strictly smaller than high bound';
    RETURN IF(lowBound < highBound, Result, ERROR(KeyLayout, 2, boundariesErrorMsg));
  END;
  
  //the key used by encode and decode functions
  SHARED errorMsg := 'MinMaxScaler: must pass either baseData or key!';
  SHARED innerKey := IF(EXISTS(key), 
                        key, 
                        IF(EXISTS(baseData), 
                          ComputeKey(), 
                          ERROR(KeyLayout, 1, errorMsg)));


  /**
   * Computes the key or reuses it if already given.
   *
   * @return the key: DATASET(KeyLayout).
   */
  EXPORT GetKey() := FUNCTION
    RETURN innerKey;
  END;
  
  
  /**
    * scales the data using the following formula:
    * x' = min + ([(x - x_min)(max - min)]/(x_max - x_min))
    *
    * @param dataToScale: DATASET(NumericField)  .         
    *   <p> The data to scale.
    *
    * @return the scaled data: DATASET(NumericField)
    */
  EXPORT Scale (DATASET(NumericField) dataToScale) := FUNCTION
    IMPORT STD;


    NumericField XF(NumericField L) := TRANSFORM
      minValue := innerKey.minsMaxs(featureId = L.number)[1].minValue;
      maxValue := innerKey.minsMaxs(featureId = L.number)[1].maxValue;
      // SELF.value := low + (((L.value - minValue) * (high - low))/(maxValue - minValue));
      SELF.value := lowBound + (((L.value - minValue) * (highBound - lowBound))/(maxValue - minValue));
      SELF := L;
    END;

    scaledData := PROJECT(dataToScale, XF(LEFT));
    RETURN scaledData;
  END; 

  /**
   * unscales the data using the following formula
   * x = x_min + ((x' - min)(x_max - x_min))/(max-min)
   *
   * @param dataToUnscale: DATASET(NumericField)         
   *  <p> The data to unscale.
   *
   * @return the unscaled data: DATASET(NumericField).
   */
  EXPORT unscale(DATASET(NumericField) dataToUnscale) := FUNCTION
    low := innerKey[1].lowBound;
    high := innerKey[1].highBound;

    NumericField XF(NumericField L) := TRANSFORM
      minValue := innerKey.minsMaxs(featureId = L.number)[1].minValue;
      maxValue := innerKey.minsMaxs(featureId = L.number)[1].maxValue;
      SELF.value := minValue + (((L.value - low) * (maxValue - minValue))/(high - low));
      SELF := L;
    END;

    unscaledData := PROJECT(dataToUnscale, XF(LEFT));
    RETURN unscaledData;
  END;
END;