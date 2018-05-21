/**
  * Macro takes any structured dataset, and appends a unique 1-based record ID
  * column to it.  Values will be in data sequence.
  * Note:  implemented as a count project, each node processes the data
  * in series instead of parallel. For better cluster performance, use
  * AppendID as long as dense, sequential ids are not needed.
  * <p>Note that, as a macro, nothing is returned, but attribute named in
  * dOut will be defined to contain the resulting dataset.
  *
  * <p>Example:
  * <pre>ML_Core.AppendSeqID(dOrig, recID, dOrigWithId);</pre>
  *
  * @param dIn The name of the input dataset.
  * @param idfield The name of the field to be appended containing the id
  *                for each row.
  * @param dOut The name of the resulting dataset.
  *
  **/
//---------------------------------------------------------------------------
// Macro takes any structured dataset, and appends a unique 1-based record ID
// column to it.  Values will be in data sequence.
// Note:  implemented as a count project, each node processes the data
// in series instead of parallel.
//
//   dIn       : The name of the input dataset
//   idfield   : The name of the field to be appended containing the id
//               for each row.
//   dOut      : The name of the resulting dataset
//
//  Examples:
//    ML_Core.AppendSeqID(dOrig, recID, dOrigWithId);
//---------------------------------------------------------------------------
EXPORT AppendSeqID(dIn,idfield,dOut) := MACRO
  #uniquename(dInPrep)
  %dInPrep%:=TABLE(dIn,{ML_Core.Types.t_RecordID idfield:=0;dIn;});
  #uniquename(tra)
  TYPEOF(%dInPrep%) %tra%(dIn L, INTEGER C) := TRANSFORM
    SELF.idfield := C;
    SELF := L;
    END;
  dOut := PROJECT(dIn,%tra%(LEFT,COUNTER));
ENDMACRO;
