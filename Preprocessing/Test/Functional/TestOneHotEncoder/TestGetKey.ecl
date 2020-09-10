/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT Preprocessing;

PTypes := Preprocessing.Types;
Comparator := Preprocessing.Utils.DatasetComparator;

/**
  * Test GetKey
  */
EXPORT TestGetKey := MODULE
  SHARED sampleData := $.testData.sample1;
  SHARED validFeatureIds := $.testData.validFeatureIds;
  SHARED invalidFeatureIds := $.testData.invalidFeatureIds;
  SHARED key := $.testData.key;
  SHARED KeyLayout := PTypes.OneHotEncoder.KeyLayout;

  /**
    * Test computation with baseData and validFeatureIds.
    */
  EXPORT TestValidInput1() := FUNCTION
    encoder := Preprocessing.OneHotEncoder(sampleData, validFeatureIds);
    result := encoder.getKey();
    expected := key;
    both := result & expected;
    deduped := DEDUP(SORT(both, number));
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestValidInput1 Failed!');
  END;

  /**
    * Test when key is passed.
    */
  EXPORT TestValidInput2() := FUNCTION
    encoder := Preprocessing.OneHotEncoder(key := key);
    result := encoder.getKey();
    expected := key;
    both := result & expected;
    deduped := DEDUP(SORT(both, number));
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestValidInput2 Failed!');
  END;

  /**
    * Test when input is empty.
    */
  EXPORT TestEmptyInput() := FUNCTION
    encoder := Preprocessing.OneHotEncoder();
    
    KeyLayout recoveryXF := TRANSFORM
      SELF.number := 0;
      SELF.startNumWhenEncoded := 0;
      SELF.categories := [];
    END;

    result := CATCH(encoder.getKey(), ONFAIL(recoveryXF));
    expected := DATASET([{0,0,[]}], KeyLayout);
    both := result & expected;
    deduped := DEDUP(SORT(both, number));
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestEmptyInput Failed!');
  END;

  /**
    * Test when feature ids are invalid.
    */
  EXPORT TestInvalidFeatureID() := FUNCTION
    encoder := Preprocessing.OneHotEncoder(sampleData, invalidFeatureIDs);
    
    KeyLayout recoveryXF := TRANSFORM
      SELF.number := 0;
      SELF.startNumWhenEncoded := 0;
      SELF.categories := [];
    END;

    result := CATCH(encoder.getKey(), ONFAIL(recoveryXF));
    expected := DATASET([{1, 1, [{0},{1}]},
                         {2, 3, []},
                         {3, 4, []}], PTypes.OneHotEncoder.keyLayout);

    both := result & expected;
    deduped := DEDUP(SORT(both, number));
    RETURN ASSERT(COUNT(deduped) = COUNT(expected), 'TestInvalidFeatureID Failed!');
  END;
END;