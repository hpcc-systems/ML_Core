/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_CORE;

Preprocessing := ML_Core.Preprocessing;

/**
  * Allows to run performance test for OneHotEncoder
  */
pathPrefix := '~Preprocessing::PerformanceTest::OneHotEncoder::';
testData := DATASET('~Preprocessing::PerformanceTest::OneHotEncoder::testData', ML_CORE.Types.NumericField , THOR);
encoder := Preprocessing.OneHotEncoder(testData, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]);
encodedData := encoder.encode(testData);
OUTPUT(encodedData,, pathPrefix + 'EncodedData', THOR, COMPRESSED, OVERWRITE);
decodedData := encoder.decode(encodedData);
OUTPUT(decodedData,, pathPrefix + 'DecodedData', THOR, COMPRESSED, OVERWRITE);
