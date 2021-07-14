/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;
IMPORT $.^.^.^ as ML_Core;

Encoder := ML_Core.Preprocessing.LabelEncoder;

FeatureListRec := RECORD
  SET OF STRING oceanProximity;
END;

featureList := ROW({[]}, FeatureListRec);
key := encoder.GetKey(Files.cleanData, featureList);
OUTPUT(key);

encodedData := encoder.encode(Files.cleanData, key);
OUTPUT(encodedData,, Files.LabelEncodedDataPath, THOR, COMPRESSED, OVERWRITE);
