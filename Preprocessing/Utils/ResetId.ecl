/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^ as MLC;
IMPORT $.Types;

NumericField := MLC.Types.NumericField;
idRec := Types.idRec;

/**
 * resets the id sequence so it starts from 1
 */
EXPORT ResetID (DATASET(NumericField) ds) := FUNCTION
  currentRowKeys := DATASET(SET(ds, id), idRec);
  keys := DEDUP(currentRowKeys);
  
  idMappingRec := RECORD
    UNSIGNED id;
    UNSIGNED key;
  END;
  
  idMappingRec assignID (idRec L, UNSIGNED cnt) := TRANSFORM
    SELF.key := L.val;
    SELF.id := cnt;
  END;

  idMapping := PROJECT(keys, assignID(LEFT, COUNTER));

  NumericField ResetID_(NumericField L) := TRANSFORM
    SELF.id := idMapping(key = L.id)[1].id;
    SELF := L;
  END;

  Result := PROJECT(ds, ResetID_(LEFT));
  RETURN Result;
END;
