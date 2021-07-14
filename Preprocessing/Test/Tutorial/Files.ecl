/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^ as MLC;

NumericField := MLC.Types.NumericField;

EXPORT Files := MODULE
  EXPORT pathPrefix := '~Preprocessing::Tutorial::CAHousing::';

  EXPORT RawDataRec := RECORD
    STRING longitude;
    STRING latitude;
    STRING housingMedianAge;
    STRING totalRooms;
    STRING totalBedrooms;
    STRING population;
    STRING households;
    STRING medianIncome;
    STRING medianHouseValue;
    STRING oceanProximity;
  END;
  EXPORT rawDataPath := pathPrefix + 'rawData';
  EXPORT rawData := DATASET(rawDataPath, RawDataRec, CSV(HEADING(1)));

  EXPORT CleanDataRec := RECORD
    UNSIGNED id;
    REAL4 longitude;
    REAL4 latitude;
    REAL4 housingMedianAge;
    REAL4 totalRooms;
    REAL4 totalBedrooms;
    REAL4 population;
    REAL4 households;
    REAL4 medianIncome;
    REAL8 medianHouseValue;
    STRING10 oceanProximity;
  END;
  EXPORT cleanDataPath := pathPrefix + 'cleanData';
  EXPORT cleanData := DATASET(cleanDataPath, CleanDataRec, THOR);

  EXPORT labelEncodedDataRec := RECORD
    RECORDOF(CleanDataRec) AND NOT oceanProximity;
    INTEGER oceanProximity;
  END;
  EXPORT labelEncodedDataPath := pathPrefix + 'labelEncodedData';
  EXPORT labelEncodedData := DATASET(labelEncodedDataPath, labelEncodedDataRec, THOR);

  EXPORT MLDataPath := pathPrefix + 'MLData';
  EXPORT MLData := DATASET(MLDataPath, NumericField, THOR);

  EXPORT xTrainPath := pathPrefix + 'xTrain';
  EXPORT xTrain := DATASET(xTrainPath, NumericField, THOR);
  EXPORT yTrainPath := pathPrefix + 'yTrain';
  EXPORT yTrain := DATASET(yTrainPath, NumericField, THOR);

  EXPORT xTestPath := pathPrefix + 'xTest';
  EXPORT xTest := DATASET(xTestPath, NumericField, THOR);
  EXPORT yTestPath := pathPrefix + 'yTest';
  EXPORT yTest := DATASET(yTestPath, NumericField, THOR);

  EXPORT cleanXTrainPath := pathPrefix + 'cleanXTrain';
  EXPORT cleanXTrain := DATASET(cleanXTrainPath, NumericField, THOR);
  EXPORT cleanXTestPath := pathPrefix + 'cleanXTest';
  EXPORT cleanXTest := DATASET(cleanXTestPath, NumericField, THOR);

  EXPORT PredictionsPath := pathPrefix + 'Predictions';
END;