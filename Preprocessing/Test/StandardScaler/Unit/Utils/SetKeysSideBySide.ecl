IMPORT Preprocessing.Ptypes;
keyRec := PTypes.StandardScaler.KeyRec;

EXPORT SetKeysSideBySide(DATASET(KeyRec) k1, DATASET(KeyRec) k2) := FUNCTION
  JoinedKeysRec := RECORD
    DATASET(KeyRec) key1;
    DATASET(KeyRec) key2;
  END;
  
  joinedKeys := DATASET([{k1, k2}], JoinedKeysRec)[1];
  RETURN joinedKeys;
END;
