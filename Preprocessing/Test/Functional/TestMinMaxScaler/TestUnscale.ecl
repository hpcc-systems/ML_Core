/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;

/**
  * Test unscale
  */
EXPORT TestUnscale := MODULE
  /**
    * Test valid input
    */
  EXPORT TestValidInput() := FUNCTION
    scaler := Preprocessing.MinMaxScaler($.TestData.sampleData);
    result := scaler.unscale($.TestData.scaledData1);
    expected := $.TestData.sampleData;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'testValidInput Failed (' + cmp + ')');
  END;

  /**
    * Test valid input 2
    */
  EXPORT TestValidInput2() := FUNCTION
    scaler := Preprocessing.MinMaxScaler($.TestData.sampleData, -100, 100);
    result := scaler.unscale($.TestData.scaledData2);
    expected := $.TestData.sampleData;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'testValidInput2 Failed (' + cmp + ')');
  END;
END;