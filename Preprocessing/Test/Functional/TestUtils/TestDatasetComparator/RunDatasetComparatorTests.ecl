/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
 * Runs all the dataset comparator tests
 */
$.TestGetFieldsInfo.TestSimpleRecord();
$.TestGetFieldsInfo.TestComplexRecord();

$.TestAreOfSameType.TestSameSimpleRecord();
$.TestAreOfSameType.TestSameComplexRecord();
$.TestAreOfSameType.TestDifferentRecord();

$.TestGetRowValuesAndTypes.TestValidInput();

$.TestAreEqualRows.TestEqualRows();
$.TestAreEqualRows.TestDifferentRows();

$.TestCompare.TestEqualData();
$.TestCompare.TestRowDifference();