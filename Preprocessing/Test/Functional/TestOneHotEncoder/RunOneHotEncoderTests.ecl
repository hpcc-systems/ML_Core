/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
  * Runs all OneHotEncoder tests
  */
$.TestIsValidInput.TestWhenDataPassed();
$.TestIsValidInput.TestWhenKeyPassed();
$.TestIsValidInput.TestWhenAllEmpty();
$.TestIsValidInput.TestEmptyFeatureIds();

$.TestGetKey.TestValidInput1();
$.TestGetKey.TestValidInput2();
$.TestGetKey.TestEmptyInput();
$.TestGetKey.TestInvalidFeatureID();

$.TestEncode.testKnownCategories();
$.TestEncode.testEmptyInput();
$.TestEncode.testUnKnownCategs();

$.TestDecode.TestGetNumberMapping();
$.TestDecode.TestKnownCategories();
$.TestDecode.TestUnKnownCategories();
$.TestDecode.TestEmptyInput();