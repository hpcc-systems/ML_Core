//---------------------------------------------------------------------------
// Macro takes any structured dataset, and appends a unique 1-based record ID
// column to it.  Values will not be sequential and values will not be
// dense because of data skew.  Gaps will appear when data ends on each
// node.  If dense and sequential values are required, use AppendSeqID
//
//   dIn       : The name of the input dataset
//   idfield   : The name of the field to be appended containing the id
//               for each row.
//   dOut      : The name of the resulting dataset
//
//  Examples:
//    ML.AppendID(dOrig, recID, dOrigWithId);
//---------------------------------------------------------------------------
EXPORT AppendID(dIn,idfield,dOut) := MACRO
  #uniquename(dInPrep)
  %dInPrep%:=TABLE(dIn,{ML_Core.Types.t_RecordID idfield:=0;dIn;});
  #uniquename(tra)
  TYPEOF(%dInPrep%) %tra%(dIn L, INTEGER C) := TRANSFORM
    SELF.idfield := (C-1)*ThorLib.nodes() + ThorLib.node() + 1;
    SELF := L;
    END;
  dOut := PROJECT(dIn,%tra%(LEFT,COUNTER), LOCAL);
ENDMACRO;
