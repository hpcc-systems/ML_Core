/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Test GetFeatureNames
  */
IMPORT $.^.^.^.^ as ML_Core;

Utils := ML_Core.Preprocessing.Utils;

EXPORT TestGetFeatureNames := MODULE
  /**
    * Test some valid input
    */
  EXPORT TestValidInput() := FUNCTION
    testLayout := RECORD
      UNSIGNED id;
      STRING feature1;
      REAL feature2;
    END;

    testData := DATASET([{1, 'a', 2.5}], testLayout);
  
    Result := Utils.GetFeatureNames(testData);
    expected := ['id', 'feature1', 'feature2'];
    RETURN ASSERT(result = expected, 'TestValidInput Failed!');
  END; 
END;
