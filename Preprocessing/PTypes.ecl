/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.^ as MLC;
IMPORT Preprocessing.Utils.Types;


NumericField := MLC.Types.NumericField;
t_FieldNumber := MLC.Types.t_FieldNumber;
t_FieldReal := MLC.Types.t_FieldReal;
valueRec := Types.valueRec;

/**
 * Record structures for ML Preprocessor modules
 */
EXPORT PTypes := MODULE
  //record structures for OneHotEncoder
  EXPORT OneHotEncoder := MODULE
    EXPORT KeyRec := RECORD
      t_FieldNumber number;
      t_FieldNumber startNumInEncData;
      DATASET(valueRec) categories;      
    END;
  END;
  
  //record structures for LabelEncoder
  EXPORT LabelEncoder := MODULE
    //record structure to store feature names and their categories
    EXPORT featureListRec := RECORD
      STRING name;
      SET OF STRING categories;
    END;
    
    //record structure for a category
    EXPORT CategoryRec := RECORD
      STRING categoryName;
      UNSIGNED value;
    END;
    
    //record for keeping mapping between categories and their assigned value
    EXPORT MappingRec := RECORD
      STRING featureName;
      DATASET(CategoryRec) categories;
    END;
  END;

  EXPORT MLNormalize := MODULE
    EXPORT NormsRec := RECORD
      UNSIGNED id;
      REAL value;
    END;
  END;
  
  //record structures for MinMaxScaler
  EXPORT MinMaxScaler := MODULE
    //record structure for storing features' min and max values
    EXPORT KeyRec := RECORD
      UNSIGNED featureID;
      REAL min_;
      REAL max_;
    END;
  END;

  //record structures for standardScaler
  EXPORT StandardScaler := MODULE
    //record structure for storing features' mean and standard deviation
    EXPORT KeyRec := RECORD
      UNSIGNED featureID;
      REAL mean_;
      REAL std_;
    END;
  END;    

  EXPORT StratifiedSplit := MODULE
    EXPORT YStatsRec := RECORD
      REAL value;
      UNSIGNED cnt;
    END;
  END;
  
  EXPORT Split := MODULE
    EXPORT SplitResultRec := RECORD
      DATASET(MLC.Types.NumericField) trainData;
      DATASET(MLC.Types.NumericField) testData;
    END;
  END;
END;
