/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Test MapCategoriesToValues
  */
IMPORT Preprocessing.Utils.LabelEncoder as E;
IMPORT Preprocessing.Test.Functional.TestLabelEncoder.TestDataAndTypes as T;

EXPORT TestMapCategoriesToValues := MODULE
  /**
    * Test some valid input
    */
  EXPORT TestValidInput() := FUNCTION
    Result := E.MapCategoriesToValues(T.key);
    expected := DATASET([{'f1', [{'cat1', 0}, {'cat2', 1}, {'cat3', 2}]},
                         {'f3', [{'1000', 0}, {'2000', 1}, {'3000', 2}]},
                         {'f4', [{'low', 0}, {'med', 1}, {'high', 2}]}], E.Types.MappingLayout);
    both := Result & expected;
    deduped := DEDUP(both, ALL);
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestValidInput Failed!');
  END; 
END;
