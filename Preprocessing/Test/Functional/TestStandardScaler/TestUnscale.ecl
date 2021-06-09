/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;

/**
  * Test UnScale
  */
EXPORT TestUnscale := MODULE
  /**
    * Test valid input
    */
  EXPORT testValidInput() := FUNCTION
    scaler := Preprocessing.StandardScaler($.testData.sampleData);
    result := scaler.unscale($.testData.scaledData);
    expected := $.testData.sampleData;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'testValidInput Failed (' + cmp + ')');
  END;
END;