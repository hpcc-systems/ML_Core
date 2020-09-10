/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Utility Record Structures for LabelEncoder Module
  */
EXPORT Types := MODULE
  //record mapping a category to its value.
  EXPORT Category := RECORD
    STRING categoryName;
    INTEGER value;
  END;

  //record mapping feature names to their categories.
  EXPORT MappingLayout := RECORD
    STRING featureName;
    DATASET(Category) categories;
  END;
  
  //record structure for labels or string values
  EXPORT LabelLayout := RECORD
    STRING label;
  END;
END;