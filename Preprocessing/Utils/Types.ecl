/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^.Types as MLCTypes;

t_Work_Item := MLCTypes.t_Work_Item;
t_RecordID := MLCTypes.t_RecordID;
t_FieldNumber := MLCTypes.t_FieldNumber;
t_FieldReal := MLCTypes.t_FieldReal;

/**
 * Utility types for Preprocessing Bundle
 */
EXPORT Types := MODULE
  EXPORT wiRec := RECORD
    t_Work_Item val;
  END;

  EXPORT idRec := RECORD
    t_RecordID val;
  END;

  EXPORT numberRec := RECORD
    t_FieldNumber val;
  END;

  EXPORT valueRec := RECORD
    t_FieldReal val;
  END;

  EXPORT ComparisonResultRec := RECORD
    BOOLEAN val;
  END;

  EXPORT IdMappingRec := RECORD
    UNSIGNED8 oldID;
    UNSIGNED8 newID;
  END;

  EXPORT StringRec := RECORD
    STRING val;
  END;
END;
