/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Test MapAFeatureCategories
  */
IMPORT $.^.^.^.^.^ as ML_Core;

Enc := ML_Core.Preprocessing.Utils.LabelEncoder;

EXPORT TestMapAFeatureCategories := MODULE
  /**
    * Test some valid input
    */
  EXPORT TestValidInput() := FUNCTION  
    Result := Enc.MapAFeatureCategories('priority', ['low', 'medium', 'high']);
    expected := DATASET([{'priority', [{'low', 0}, {'medium', 1}, {'high', 2}]}], Enc.Types.MappingLayout);
    both := Result & expected;
    deduped := DEDUP(both, ALL);
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestValidInput Failed!');
  END; 
END;
