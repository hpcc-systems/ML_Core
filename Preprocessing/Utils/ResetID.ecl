/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^ as ML_Core;
IMPORT STD;

Types := ML_Core.Preprocessing.Types;
NumericField := ML_Core.Types.NumericField;
idLayout := Types.idLayout;
t_RecordID := ML_Core.Types.t_RecordID;

/**
 * resets the id sequence so it starts from 1.
 *
 * @param ds: DATASET(NumericField).
 *   <p> The dataset with unordered ids.
 *
 * @return dataset with ordered ids.
 */
EXPORT ResetID (DATASET(NumericField) ds) := FUNCTION  
  ids := DEDUP(DATASET(SET(ds, id), idLayout));
  
  idMappingLayout := RECORD
    t_RecordID unorderedID;
    t_RecordID orderdedID;
  END;
  
  //determine correct id
  idMappingLayout assignID (Types.idLayout L, t_RecordID cnt) := TRANSFORM
    SELF.unorderedID := L.id;
    SELF.orderdedID := cnt;
  END;

  idMapping := PROJECT(ids, assignID(LEFT, COUNTER));
  
  //fix ids
  NumericField ResetID_(NumericField L) := TRANSFORM
    SELF.id := idMapping(unorderedID = L.id)[1].orderdedID;
    SELF := L;
  END;

  Result := PROJECT(ds, ResetID_(LEFT));
  RETURN Result;
END;