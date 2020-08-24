/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.TestLabelEncoder;
IMPORT $.^.^.^.^ as ML_CORE;

testData := DATASET('~Preprocessing::PerformanceTest::LabelEncoder::encodedData', TestLabelEncoder.Files.EncodedDataLayout, THOR);
ML_CORE.ToField(testData, testDataNF);
OUTPUT(testDataNF,, '~Preprocessing::PerformanceTest::OneHotEncoder::testData', THOR, COMPRESSED, OVERWRITE);


