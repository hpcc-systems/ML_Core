/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;

Files.CleanDataRec clean (Files.RawDataRec L, UNSIGNED cnt) := TRANSFORM
  SELF.id := cnt;
  SELF.longitude := (REAL4) L.longitude;
  SELF.latitude := (REAL4) L.latitude;
  SELF.housingMedianAge := (REAL4) L.housingMedianAge;
  SELF.totalRooms := (REAL4) L.totalRooms;
  SELF.totalBedrooms :=  IF(L.totalBedrooms = '', 0.0, (REAL4)L.totalBedrooms);
  SELF.population := (REAL4) L.population;
  SELF.households := (REAL4) L.households;
  SELF.medianIncome := (REAL4) L.medianIncome;
  SELF.medianHouseValue := (REAL8) L.medianHouseValue;
  SELF.oceanProximity := (STRING10) L.oceanProximity;    
END;

cleanData := PROJECT(Files.rawData, clean(LEFT, COUNTER));
OUTPUT(cleanData(totalBedrooms <> 0.0),, Files.cleanDataPath, THOR, COMPRESSED, OVERWRITE);