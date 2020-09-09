/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
  * Runs all standard scaler tests
  */
//$.TestGetKey.TestEmptyInput();
$.TestGetKey.TestKeyComputation();
$.TestGetKey.TestKeyReuse();

$.TestScale.testValidInput();

$.TestUnscale.testValidInput();