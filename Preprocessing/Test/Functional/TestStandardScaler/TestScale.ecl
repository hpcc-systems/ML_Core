/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;

/**
  * Test Scale
  */
EXPORT TestScale := MODULE
  /**
    * Test valid input
    */
  EXPORT testValidInput() := FUNCTION
    scaler := Preprocessing.StandardScaler($.testData.sampleData);
    result := scaler.scale($.testData.sampleData);
    expected := $.testData.scaledData;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'testValidInput Failed (' + cmp + ')');
  END;
END;