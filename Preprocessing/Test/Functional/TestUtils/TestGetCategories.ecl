/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Test GetCategories function
  */
IMPORT Preprocessing.Utils;

EXPORT TestGetCategories := MODULE
  /**
    * Test with some valid input
    */
  EXPORT TestValidInput() := FUNCTION
    testData := DATASET([{1, 'low'},
                         {2, 'med'},
                         {3, 'high'},
                         {4, 'med'},
                         {5, 'low'}], {UNSIGNED id, STRING category});
    
    result := Utils.GetCategories(testData, category);
    expected := ['high', 'low', 'med'];
    RETURN ASSERT(result = expected, 'TestValidInput Failed');
  END;
END;
