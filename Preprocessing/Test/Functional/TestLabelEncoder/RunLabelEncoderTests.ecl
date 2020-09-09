/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Runs all label encoder functional tests
 */
$.TestGetKey.TestValidInput();

$.TestEncode.TestValidInput();
$.TestEncode.TestUnknownCategories();

$.TestDecode.TestValidInput();
$.TestDecode.TestUnknownCategories();