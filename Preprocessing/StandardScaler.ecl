/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;
KeyLayout := ML_Core.Preprocessing.Types.StandardScaler.KeyLayout;

/**
  * Allow to scale the values such that they have a zero mean and unit variance.
  *
  * @param baseData: DATASET(NumericField), default = DATASET([], Types.NumericField)
  *   <p> The data from which the means and standard deviations are determined for each feature.
  *
  * @param key: DATASET(KeyLayout), default = DATASET([], KeyRec)
  *   <p> The key to be reused for scaling/unscaling.
  *
  * @see MinMaxScaler
  */
EXPORT StandardScaler(DATASET(NumericField) baseData = DATASET([], NumericField), 
                      DATASET(KeyLayout) key = DATASET([], KeyLayout)) := MODULE

  SHARED Preprocessing := ML_Core.Preprocessing;
  SHARED valueLayout := Preprocessing.Types.valueLayout;
  SHARED numberLayout := Preprocessing.Types.numberLayout;

  /**
    * Computes averages and stdevs for each feature in baseData.
    *
    * @return avgandStdevByFeature: DATASET(KeyLayout).
    */
  SHARED ComputeKey() := FUNCTION    
    KeyLayout compute(numberLayout L) := TRANSFORM
      SELF.featureId := L.number;
      values := SET(baseData(number = L.number), value);
      SELF.avg := AVE(values);
      SELF.stdev := SQRT(VARIANCE(DATASET(values, valueLayout), value));
    END;

    featureIds := DATASET(SET(baseData(id = 1), number), numberLayout);
    Result := PROJECT(featureIds, compute(LEFT));
    RETURN Result;
  END;

  //the key used by encode and decode functions
  SHARED errorMsg := 'StandardScaler: must pass either baseData or key!';
  SHARED innerKey := IF(EXISTS(key), 
                        key, 
                        IF(EXISTS(baseData), 
                          ComputeKey(), 
                          ERROR(KeyLayout, 1, errorMsg)));

  /**
    * Computes the average and standard deviation per feature or reuses the key if provided.
    *
    * @return key: DATASET(KeyLayout).
    */
  EXPORT GetKey() := FUNCTION
    RETURN innerKey;
  END;
  
  /**
    * scales the data using the following formula
    * x' = (x - avg)/stdev
    *
    * @param dataToScale: DATASET(NumericField).
    *   <p> The data to scale
    *
    * @return the scaled data: DATASET(NumericField)
    */
  EXPORT Scale (DATASET(NumericField) dataToScale) := FUNCTION
    NumericField XF(NumericField L) := TRANSFORM
      avg := innerKey(featureID = L.number)[1].avg;
      stdev := innerKey(featureID = L.number)[1].stdev;
      SELF.value := (L.value - avg)/stdev;
      SELF := L;
    END;

    scaledData := PROJECT(dataToScale, XF(LEFT));
    RETURN scaledData;
  END;

  /**
    * unscales the data using the following formula:
    * x = (x' * stdev) + avg
    *
    * @param dataToUnscale: DATASET(NumericField).         
    *   <p> The data to unscale.
    *
    * @return the unscaled data: DATASET(NumericField).
    */
  EXPORT unscale(DATASET(NumericField) dataToUnscale) := FUNCTION
    NumericField XF(NumericField L) := TRANSFORM
      avg := innerKey(featureId = L.number)[1].avg;
      stdev := innerKey(featureId = L.number)[1].stdev;
      SELF.value := (L.value * stdev) + avg;
      SELF := L;
    END;
    
    unscaledData := PROJECT(dataToUnscale, XF(LEFT));
    RETURN unscaledData;
  END;
END;