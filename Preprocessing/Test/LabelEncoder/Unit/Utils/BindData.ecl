EXPORT BindData(d1, d2) := FUNCTIONMACRO
  ResultRec := RECORD
    TYPEOF(d1) ds1;
    TYPEOF(d2) ds2;
  END;
  
  Result := DATASET([{d1, d2}], ResultRec)[1];
  RETURN Result;
ENDMACRO;
