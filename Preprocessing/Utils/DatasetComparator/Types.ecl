/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

/**
  * Record structures for dataset comparator modules and functions.
  */
EXPORT Types := MODULE
  //record storing a field's information
  EXPORT FieldInfo := RECORD
    UNSIGNED position;
    STRING name;
    STRING dataType;
    STRING size;    
  END; 
  
  //record for a field's type and value
  EXPORT FieldTypeAndValue := RECORD
    STRING dataType;
    STRING value;
  END;
END;