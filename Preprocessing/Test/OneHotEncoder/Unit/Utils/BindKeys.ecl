IMPORT Preprocessing.Ptypes;
keyRec := PTypes.OneHotEncoder.KeyRec;

EXPORT BindKeys(DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  ResultRec := RECORD
    DATASET(KeyRec) key1;
    DATASET(KeyRec) key2;
  END;
  
  Result := DATASET([{k1, k2}], ResultRec)[1];
  RETURN Result;
END;
