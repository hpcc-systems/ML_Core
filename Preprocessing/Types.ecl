/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.Types as MLCTypes;

t_FieldNumber := MLCTypes.t_FieldNumber;
t_FieldReal := MLCTypes.t_FieldReal;

/**
  * Record structures for Preprocessing modules
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

  /**
    * record structures for OneHotEncoder
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
    * record structures for StandardScaler
    */
  EXPORT StandardScaler := MODULE
    //record structure for storing features' average and standard deviation
    EXPORT KeyLayout := RECORD
      t_FieldNumber featureId;
      t_FieldReal avg;
      t_FieldReal stdev;
    END;
  END;

  //record structures for MinMaxScaler
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
END;