/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.^.^ as ML_Core;

Preprocessing := ML_Core.Preprocessing;
Comparator := Preprocessing.Utils.DatasetComparator;

/**
  * Test GetKey()
  */
EXPORT TestGetKey := MODULE
  SHARED key := $.TestData.key;

  /**
    * Test key computation
    */
  EXPORT TestKeyComputation() := FUNCTION
    scaler := Preprocessing.StandardScaler($.testData.sampleData);
    result := scaler.getKey();
    expected := key;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestKeyComputation Failed (' + cmp + ')');
  END;

  /**
    * Test key reuse
    */
  EXPORT TestKeyReuse() := FUNCTION
    scaler := Preprocessing.StandardScaler(key := $.testData.key);
    result := scaler.getKey();
    expected := key;
    cmp := Comparator.compare(result, expected);
    RETURN ASSERT(cmp = 0, 'TestKeyReuse Failed (' + cmp + ')');
  END;

  /**
    * Test with empty input
    */
  EXPORT TestEmptyInput() := FUNCTION    
    KeyLayout := Preprocessing.Types.StandardScaler.KeyLayout;

    KeyLayout recoveryXF := TRANSFORM
      SELF.featureId := 0;
      SELF.avg := 0.0;
      SELF.stdev := 0.0;
    END;

    scaler := Preprocessing.StandardScaler();
    result := CATCH(scaler.getKey(), ONFAIL(recoveryXF));
    //expected := DATASET([{0,0,0}], KeyLayout);
    //cmp := Comparator.compare(result, expected);
    //RETURN ASSERT(cmp = 0, 'TestEmptyInput Failed (' + cmp + ')');
    RETURN result;
  END;
END;
