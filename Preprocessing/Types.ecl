/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^ as ML_Core;

MLCTypes := ML_Core.Types;
t_FieldNumber := MLCTypes.t_FieldNumber;
t_FieldReal := MLCTypes.t_FieldReal;
t_RecordID := MLCTypes.t_RecordID;

/**
  * Record structures for Preprocessing modules.
  */
EXPORT Types := MODULE
  //record structure for storing REAL values
  EXPORT valueLayout := RECORD
    t_FieldReal value;
  END;

  //record structure for storing numbers
  EXPORT numberLayout := RECORD
    t_FieldNumber number;
  END;

  //record structure for storing ids
  EXPORT idLayout := RECORD
    t_RecordID id;
  END;

  /**
    * record structures for OneHotEncoder.
    */
  EXPORT OneHotEncoder := MODULE
    //record structure for key.
    EXPORT KeyLayout := RECORD
      t_FieldNumber number;
      t_FieldNumber startNumWhenEncoded;
      DATASET(valueLayout) categories;      
    END;
    
    //record mapping the number field when encoded and when decoded.
    EXPORT numberMapping := RECORD
      t_FieldNumber numberWhenEncoded;
      t_FieldNumber numberWhenDecoded;
    END;
  END;

  /**
    * record structures for StandardScaler.
    */
  EXPORT StandardScaler := MODULE
    //record structure for storing features' average and standard deviation
    EXPORT KeyLayout := RECORD
      t_FieldNumber featureId;
      t_FieldReal avg;
      t_FieldReal stdev;
    END;
  END;

  /**
    * record structures for MinMaxScaler.
    */
  EXPORT MinMaxScaler := MODULE
    //record structure for storing a feature's min and max value
    EXPORT FeatureMinMax := RECORD
      t_FieldNumber featureId;
      t_FieldReal minValue;
      t_FieldReal maxValue;
    END;

    //record structure for storing features' mins and max values as well as lowest
    //and highest value for scaling
    EXPORT KeyLayout := RECORD
      t_FieldReal lowBound;
      t_FieldReal highBound;
      DATASET(FeatureMinMax) minsMaxs;
    END;
  END;
  
  /**
    * record structures for normalize function.
    */
  EXPORT Normaliz := MODULE
    //norms layout
    EXPORT normsLayout := RECORD
      t_RecordID id;
      t_FieldReal value;
    END;
  END;
END;