/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;
IMPORT $.TestData;

Preprocessing := ML_Core.Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;

IMPORT $.^.^.^.^ as MLC;
NumericField := MLC.Types.NumericField;

/**
  * Test the normaliz function
  */
EXPORT TestNormaliz := MODULE
  /**
    * Test L1 norm
    */
  EXPORT TestL1Norm() := FUNCTION
    result := Preprocessing.Normaliz(testData.sampleData, 'l1');
    expected := $.testData.l1NormResult;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestL1Norm Failed (' + cmp + ')');
  END;

  /**
    * Test L2 norm
    */
  EXPORT TestL2Norm() := FUNCTION
    result := Preprocessing.Normaliz(testData.sampleData, 'l2');
    expected := $.testData.l2NormResult;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestL2Norm Failed (' + cmp + ')');
  END;

  /**
    * Test L-infinity norm
    */
  EXPORT TestLInfNorm() := FUNCTION
    result := Preprocessing.Normaliz(testData.sampleData, 'inf');
    expected := $.testData.lInfNormResult;
    cmp := Comparator.Compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestLInfNorm Failed (' + cmp + ')');
  END;
END;