/**
  * Macro takes any structured dataset, and appends a unique 1-based record ID
  * column to it.  Values will not be sequential and values will not be
  * dense because of data skew.  Gaps will appear when data ends on each
  * node.  If dense and sequential values are required, use AppendSeqID.
  * <p>Note that, as a macro, nothing is returned, but attribute named in
  * dOut will be defined to contain the resulting dataset.
  *
  * <p>Example:
  * <pre>ML_Core.AppendID(dOrig, recID, dOrigWithId);</pre>
  *
  * @param dIn The name of the input dataset.
  * @param idfield The name of the field to be appended containing the id
  *                for each row.
  * @param dOut The name of the resulting dataset.
  *
  **/
EXPORT AppendID(dIn,idfield,dOut) := MACRO
  IMPORT Std.System.ThorLib;
  #uniquename(dInPrep)
  %dInPrep%:=TABLE(dIn,{ML_Core.Types.t_RecordID idfield:=0;dIn;});
  #uniquename(tra)
  TYPEOF(%dInPrep%) %tra%(dIn L, INTEGER C) := TRANSFORM
    SELF.idfield := (C-1)*ThorLib.nodes() + ThorLib.node() + 1;
    SELF := L;
    END;
  dOut := PROJECT(dIn,%tra%(LEFT,COUNTER), LOCAL);
ENDMACRO;
