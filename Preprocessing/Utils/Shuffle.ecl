/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT $.^.^ as ML_Core;

NumericField := ML_Core.Types.NumericField;
Types := ML_Core.Preprocessing.Types;

//Layout for keeping old and new id values.
IdMappingLayout := RECORD
  ML_Core.Types.t_RecordID oldID;
  ML_Core.Types.t_RecordID newID;
END;

/**
 * sets wi and id of every row in data by newWi and newId.
 *
 * @param ds: DATASET(NumericField).
 *   <p> input data.
 *
 * @param newWi: t_Work_Item.
 *   <p> the new work item value.
 *
 * @param newId: t_Work_Item.
 *   <p> the new id value.
 *
 * @return the updated data: DATASET(NumericField).
 */
SetWiAndId (DATASET(NumericField) ds, 
            ML_Core.Types.t_Work_Item newWi, ML_Core.Types.t_RecordID newId) := FUNCTION

  NumericField XF (NumericField L) := TRANSFORM
    SELF.wi := newWi;
    SELF.id := newId;
    SELF := L;
  END;

  Result := PROJECT(ds, XF(LEFT));
  Return Result;
END;

/**
 * Shuffle the ids.
 *
 * @param ids: DATASET(idLayout).
 *   <p> the ids to shuffle.
 *
 * @return idMapping: DATASET(idMappingLayout).
 *   <p> Mapping between old ids and new ids (ids after shuffling).
 */
shuffleIds(DATASET(Types.idLayout) ids) := FUNCTION
  shuffledIDLayout := RECORD(Types.idLayout)
    UNSIGNED4 rnd;
  END;

  idsWithRnd := PROJECT(ids, TRANSFORM(shuffledIDLayout, SELF.rnd := RANDOM(), SELF := LEFT));
  shuffledIds := SORT(idsWithRnd, rnd);

  IdMappingLayout mapID (Types.idLayout L) := TRANSFORM
    SELF.oldID := L.id;
    SELF.newID := shuffledIds[L.id].id;
  END;
  
  Result := PROJECT(ids, mapID(LEFT));
  RETURN Result;
END;

/**
 * shuffles a numericField dataset.
 *
 * @param dataToShuffle: DATASET(NumericField).
 *  <p> the data to shuffle.
 *
 * @return shuffled data: DATASET(NumericField).
 */
EXPORT shuffle(DATASET(NumericField) dataToShuffle) := FUNCTION
  ids := DEDUP(DATASET(SET(dataToShuffle, id), Types.idLayout));
  idMapping := shuffleIds(ids); //mapping between old ids and ids after shuffling.

  LoopLayout := RECORD
    UNSIGNED cnt;
    DATASET(NumericField) shuffledData;
  END;
  
  //looping through each id and replacing each row values by the values from row after shuffling.
  initialResult := DATASET([{1, DATASET([], NumericField)}], LoopLayout);
  loopResult := LOOP(initialResult,
                     COUNT(ids),
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(LoopLayout,
                        currentData := dataToShuffle(id = ids[LEFT.cnt].id);
                        newData := dataToShuffle(id = idMapping[LEFT.cnt].newID);
                        SELF.shuffledData := LEFT.shuffledData 
                                        + SetWiAndId(newData, currentData[1].wi, currentData[1].id);
                        SELF.cnt := LEFT.cnt + 1)));
  
  RETURN loopResult[1].shuffledData;
END;