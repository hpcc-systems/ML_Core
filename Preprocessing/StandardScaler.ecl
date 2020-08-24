/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;
IMPORT Preprocessing.PTypes;
IMPORT Preprocessing.Utils;

NumericField := MLC.Types.NumericField;
KeyRec := PTypes.StandardScaler.KeyRec;
numberRec := Utils.Types.NumberRec;
valueRec := Utils.Types.valueRec;

/**
 * shifts the values such that they have a zero mean and unit variance
 *
 * @param baseData: DATASET(NumericField), default = DATASET([], Types.NumericField)
 *   the data from which the means and stds are determined
 *
 * @param key: PTypes.StandardScaler.KeyRec, default = DATASET([], KeyRec)
 *   the key to be reused for scaling/unscaling
 *
 * @see MinMaxScaler
 */
EXPORT StandardScaler(DATASET(NumericField) baseData = DATASET([], NumericField), 
                      DATASET(KeyRec) key = DATASET([], KeyRec)) := MODULE
  
  /**
   * Compute mean and std by feature
   *
   * @return meanAndStdByFeature
   */
  SHARED GetMeanAndStdByFeature() := FUNCTION
    featureIDs := Utils.GetFeatureIDs(baseData);
    
    KeyRec GetMeanAndStd(NumberRec featureID) := TRANSFORM
      SELF.featureID := featureID.val;
      featureValues := SET(baseData(number = featureID.val), value);
      SELF.mean_ := AVE(featureValues);
      SELF.std_ := SQRT(VARIANCE(DATASET(featureValues, valueRec), val));
    END;

    meanAndStdByFeature := PROJECT(featureIDs, GetMeanAndStd(LEFT));
    RETURN meanAndStdByFeature;
  END;

  /**
   * The key has mean and standard deviation per feature
   *
   * @return key
   */
  EXPORT GetKey() := FUNCTION
    key_ := IF(COUNT(key) = 0, GetMeanAndStdByFeature(), key);
    RETURN IF(COUNT(key_) <> 0, key_, ERROR(keyRec, 'StandardScaler Key is Empty'));
  END;

  /**
   * scales the data using the following formula
   * x' = (x - mean)/std
   *
   * @param dataToScale: DATASET(NumericField)
   *   the data to scale
   *
   * @return the scaled data
   */
  EXPORT Scale (DATASET(NumericField) dataToScale) := FUNCTION
    key_ := IF(COUNT(key) = 0, GetKey(), key);

    NumericField scaleRow(NumericField currentRow) := TRANSFORM
      mean_ := key_(featureID = currentRow.number)[1].mean_;
      std_ := key_(featureID = currentRow.number)[1].std_;
      SELF.value := (currentRow.value - mean_)/std_;
      SELF := currentRow;
    END;

    scaledData := PROJECT(dataToScale, scaleRow(LEFT));
    RETURN scaledData;
  END;

  /**
   * unscales the data using the following formula:
   * x = (x' * std) + mean
   *
   * @param dataToUnscale: DATASET(NumericField)         
   *   the data to unscale
   *
   * @return the unscaled data
   */
  EXPORT unscale(DATASET(NumericField) dataToUnscale) := FUNCTION
    key_ := IF(COUNT(key) = 0, GetKey(), key);

    NumericField unscaleRow(NumericField currentRow) := TRANSFORM
      mean_ := key_(featureID = currentRow.number)[1].mean_;
      std_ := key_(featureID = currentRow.number)[1].std_;
      SELF.value := (currentRow.value * std_) + mean_;
      SELF := currentRow;
    END;
    
    unscaledData := PROJECT(dataToUnscale, unscaleRow(LEFT));
    RETURN unscaledData;
  END;
END;
