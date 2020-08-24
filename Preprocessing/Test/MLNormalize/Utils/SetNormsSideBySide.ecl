IMPORT Preprocessing.Ptypes;
normsRec := PTypes.MLNormalize.NormsRec;

EXPORT SetNormsSideBySide(DATASET(normsRec) n1, DATASET(normsRec) n2) := FUNCTION
  NormsRec := RECORD
    DATASET(normsRec) empiricalNorm;
    DATASET(normsRec) expectedNorm;
  END;
  
  norms := DATASET([{n1, n2}], NormsRec)[1];
  RETURN norms;
END;
