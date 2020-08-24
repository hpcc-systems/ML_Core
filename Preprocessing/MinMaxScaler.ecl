/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;
IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

KeyRec := PTypes.MinMaxScaler.KeyRec;
NumericField := MLC.types.NumericField;

/**
 * shifts the values in a range [min, max]
 *
 * @param baseData: DATASET(NumericField), Default = DATASET([], NumericField)            
 *   the data from which the minimums and maximums are determined
 *
 * @param min: REAL8, Default = 0.0                     
 *   the minimum value of the normalized data
 *
 * @param max: REAL8, Default = 1.0                     
 *   the maximum value of the normalized data
 *
 * @param key: PTypes.MinMaxScaler.KeyRec, default = DATASET([], KeyRec)            
 *   the key to be reused for scaling/unscaling
 *
 * @see StandardScaler
 */
EXPORT MinMaxScaler (DATASET(NumericField) baseData = DATASET([], NumericField),
                     REAL8 minVal = 0.0, REAL8 maxVal = 1.0, 
                     DATASET(KeyRec) key = DATASET([], KeyRec)) := MODULE
  /**
   * Get minimum and maximum for each feature in baseData
   *
   * @return minAndMaxByFeature
   */
  SHARED GetMinAndMaxByFeature() := FUNCTION
    numberRec := Utils.Types.numberRec;
    featureIds := DATASET(SET(baseData(id = 1), number), numberRec);
    
    KeyRec GetMinAndMax(numberRec L) := TRANSFORM
      SELF.featureID := L.val;
      values := SET(baseData(number = L.val), value);
      SELF.min_ := MIN(values);
      SELF.max_ := MAX(values);
    END;

    Result := PROJECT(featureIds, GetMinAndMax(LEFT));
    RETURN Result;
  END;

  /**
   * Computes the key used for scaling/unscaling
   * <p> The key has minimums and maximums per feature
   *
   * @return the key
   */
  EXPORT GetKey() := FUNCTION
    minMaxAreValid := IF(minVal < maxVal, TRUE, FALSE);
    key_ := IF(COUNT(key) = 0, GetMinAndMaxByFeature(), key);
    minMaxError := ERROR(keyRec, 'MinVal must be strictly less than maxVal');
    emptyKeyError := ERROR(keyRec, 'MinMaxScaler Key is Empty');
    RETURN IF(COUNT(key_) <> 0, IF(minMaxAreValid, key_, minMaxError), emptyKeyError);
  END;
  
  
  /**
   * scales the data using the following formula:
   * x' = min + ([(x - x_min)(max - min)]/(x_max - x_min))
   *
   * @param dataToScale: DATASET(NumericField)           
   *   the data to scale
   *
   * @return the scaled data
   */
  EXPORT Scale (DATASET(NumericField) dataToScale) := FUNCTION
    key_ := IF(COUNT(key) = 0, GetKey(), key);

    NumericField scaleRow(NumericField currentRow) := TRANSFORM
      min_ := key_(featureID = currentRow.number)[1].min_;
      max_ := key_(featureID = currentRow.number)[1].max_;
      SELF.value := minVal + (((currentRow.value - min_) * (maxVal - minVal))/(max_ - min_));
      SELF := currentRow;
    END;

    scaledData := PROJECT(dataToScale, scaleRow(LEFT));
    RETURN scaledData;
  END; 

  /**
   * unscales the data using the following formula
   * x = xMin + ((x' - min)(xMax-xMin))/(max-min)
   *
   * @param dataToUnscale: DATASET(NumericField)         
   *  the data to unscale
   *
   * @return the unscaled data
   */
  EXPORT unscale(DATASET(NumericField) dataToUnscale) := FUNCTION
    key_ := IF(COUNT(key) = 0, GetKey(), key);

    NumericField unscaleRow(NumericField currentRow) := TRANSFORM
      min_ := key_(featureID = currentRow.number)[1].min_;
      max_ := key_(featureID = currentRow.number)[1].max_;
      SELF.value := min_ + (((currentRow.value - minVal) * (max_ - min_))/(maxVal - minVal));
      SELF := currentRow;
    END;

    unscaledData := PROJECT(dataToUnscale, unscaleRow(LEFT));
    RETURN unscaledData;
  END;
END;