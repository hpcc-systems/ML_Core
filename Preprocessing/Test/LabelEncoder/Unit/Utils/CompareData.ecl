IMPORT Preprocessing.Test.LabelEncoder.Unit.TestData;
IMPORT Preprocessing.Utils.Types;

DataRec := TestData.Layout;
EncodedDataRec := TestData.EncodedLayout;

EXPORT CompareData(d1, d2) := FUNCTIONMACRO
  compareRowByRow (ds1, ds2) := FUNCTIONMACRO
    IMPORT Preprocessing.Utils as U;
    comparisonResultRec := U.Types.comparisonResultRec;
    rowIDs := U.GetRowIDs(COUNT(ds1));

    comparisonResultRec compare(Types.idRec rowID) := TRANSFORM
      id := rowID.val;
      id1 := ds1[id].id;
      id2 := ds2[id].id;
      f11 := ds1[id].f1;
      f12 := ds2[id].f1;
      f21 := ds1[id].f2;
      f22 := ds2[id].f2;
      f31 := ds1[id].f3;
      f32 := ds2[id].f3;
      f41 := ds1[id].f4;
      f42 := ds2[id].f4;

      SELF.val := IF(id1 = id2 AND f11 = f12 AND f21 = f22 AND f31 = f32 AND f41 = f42, TRUE, FALSE);
    END;

    comparisonRowByRow := PROJECT(rowIDs, compare(LEFT));

    result := IF(COUNT(comparisonRowByRow(val = FALSE)) <> 0, FALSE, TRUE);
    RETURN result;
  ENDMACRO;
  
  comparisonResult := IF(COUNT(d1) = COUNT(d2), compareRowByRow(d1, d2), FALSE);
  RETURN comparisonResult;
ENDMACRO;