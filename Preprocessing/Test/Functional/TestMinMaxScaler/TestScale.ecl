/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;

/**
  * Test scale
  */
EXPORT TestScale := MODULE
  /**
    * Test valid input
    */
  EXPORT TestValidInput() := FUNCTION
    scaler := Preprocessing.MinMaxScaler($.TestData.sampleData);
    result := scaler.scale($.TestData.sampleData);
    expected := $.TestData.scaledData1;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'testValidInput Failed (' + cmp + ')');
  END;

  /**
    * Test valid input 2
    */
  EXPORT TestValidInput2() := FUNCTION
    scaler := Preprocessing.MinMaxScaler($.TestData.sampleData, -100, 100);
    result := scaler.scale($.TestData.sampleData);
    expected := $.TestData.scaledData2;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'testValidInput2 Failed (' + cmp + ')');
  END;
END;