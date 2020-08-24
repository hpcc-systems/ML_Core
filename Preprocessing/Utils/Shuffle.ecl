/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

IMPORT ML_CORE.Types;

/**
 * sets wi and id
 */
SetWiAndId (DATASET(Types.NumericField) ds, Types.t_Work_Item wi, Types.t_RecordID id) := FUNCTION
  Types.NumericField setWiAndIdOfRow (Types.NumericField currentRow) := TRANSFORM
    SELF.wi := wi;
    SELF.id := id;
    SELF := currentRow;
  END;

  Result := PROJECT(ds, setWiAndIdOfRow(LEFT));
  Return Result;
END;

/**
 * Shuffle the dataset ids
 */
shuffleIds(DATASET($.Types.idRec) ids) := FUNCTION
  shuffledIDRec := RECORD($.Types.idRec)
    UNSIGNED4 rnd;
  END;

  idsWithRnd := PROJECT(ids, TRANSFORM(shuffledIDRec, SELF.rnd := RANDOM(), SELF := LEFT));
  shuffledIds := SORT(idsWithRnd, rnd);

  rowIds := $.GetRowIds(COUNT(ids));

  $.Types.IdMappingRec mapID ($.Types.idRec idx) := TRANSFORM
    SELF.oldID := ids[idx.val].val;
    SELF.newID := shuffledIds[idx.val].val;
  END;
  
  Result := PROJECT(rowIds, mapID(LEFT));
  RETURN Result;
END;

/**
 * shuffles a numericField dataset
 */
EXPORT shuffle(DATASET(Types.NumericField) dataToShuffle) := FUNCTION
  ids := $.GetIdsFromNF(dataToShuffle);
  idMapping := shuffleIds(ids);

  loopRec := RECORD
    UNSIGNED cnt;
    DATASET(Types.NumericField) shuffledData;
  END;

  initialResult := DATASET([{1, DATASET([], Types.NumericField)}], loopRec);
  loopResult := LOOP(initialResult,
                     COUNT(ids),
                     PROJECT(ROWS(LEFT), 
                      TRANSFORM(loopRec,
                        currentData := dataToShuffle(id = ids[LEFT.cnt].val);
                        newData := dataToShuffle(id = idMapping[LEFT.cnt].newID);
                        SELF.shuffledData := LEFT.shuffledData + SetWiAndId(newData, currentData[1].wi, currentData[1].id);
                        SELF.cnt := LEFT.cnt + 1)));
  
  ResultRec := RECORD
    DATASET(Types.NumericField) ds;
    DATASET($.Types.IdMappingRec) idMapping;
  END;

  Result := DATASET([{loopResult[1].shuffledData, idMapping}], ResultRec);
  RETURN Result;
END;