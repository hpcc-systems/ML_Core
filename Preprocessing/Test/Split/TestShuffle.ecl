/**
 * Test shuffle
 */

IMPORT Preprocessing;
IMPORT $.^.^.^ as MLC;
IMPORT Preprocessing.Utils;
IMPORT $.TestData;

NumericField := MLC.Types.NumericField;

compareNF (DATASET(NumericField) d1, DATASET(NumericField) d2) := FUNCTION
  comparisonResultRec := Utils.Types.comparisonResultRec;
  rowIDs := Utils.GetRowIDs(COUNT(d1));

  comparisonResultRec compare(Utils.Types.idRec rowID) := TRANSFORM
    id := rowID.val;
    wi1 := d1[id].wi;
    wi2 := d2[id].wi;
    number1 := d1[id].number;
    number2 := d2[id].number;
    value1 := d1[id].value;
    value2 := d2[id].value;

    SELF.val := IF(wi1 = wi2 AND number1 = number2 AND value1 = value2, TRUE, FALSE);
  END;

  comparisonRowByRow := PROJECT(rowIDs, compare(LEFT));

  comparisonResult := IF(COUNT(comparisonRowByRow(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN comparisonResult;
END;

compareData (DATASET(NumericField) ds, DATASET(NumericField) shuffledDS, DATASET(Utils.Types.IdMappingRec) idMappings) := FUNCTION
  Utils.Types.ComparisonResultRec compare(Utils.Types.IdMappingRec currentRow) := TRANSFORM
    d1 := ds(id = currentRow.newID);
    d2 := shuffledDS(id = currentRow.oldID);
    SELF.val := compareNF(d1, d2);
  END;

  compResult := PROJECT(idMappings, compare(LEFT));
  Result := IF(COUNT(compResult(val = FALSE)) <> 0, FALSE, TRUE);
  RETURN Result;
END;

MLC.toField(testData.sampleData, sampleDataNF);
shuffledData := Utils.shuffle(sampleDataNF);

ASSERT(COUNT(sampleDataNF) = COUNT(shuffledData.ds), 'Count Shuffled data is different from expected');
OUTPUT(Utils.bindNF(sampleDataNF, shuffledData.ds));
OUTPUT(shuffledData.IdMapping, NAMED('IdMapping'));
ASSERT(compareData(sampleDataNF, shuffledData.ds, shuffledData.IdMapping) = TRUE, 'Shuffling failed');
