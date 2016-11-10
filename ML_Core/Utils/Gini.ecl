/**
 * Creates a file of pivot/target pairs with a Gini impurity value.
 *@param infile the input file, any type with a work item field
 *@param pivot  the name of the pivot field
 *@param target the name of the field used as the target
 *@param wi_name the name of the work item field, default is "wi"
 *return        A table by Work Item and Pivot value giving count and
 *              Gini impurity value
 */
EXPORT Gini(infile, pivot, target, wi_name='wi') := FUNCTIONMACRO
  // First count up the values of each target for each pivot
  LOCAL agg := TABLE(infile,
                     {wi_name, pivot, target, Cnt:=COUNT(GROUP)},
                     wi_name, pivot, target, MERGE);
  // Now compute the total number for each pivot
  LOCAL aggc := TABLE(agg, {wi_name, pivot, TCnt:=SUM(GROUP,Cnt)},
                      wi_name, pivot, MERGE);
  LOCAL r := RECORD
    agg;
    REAL4 Prop; // Proportion pertaining to this dependant value
  END;
  // Now on each row we have the proportion of the node that is that dependant value
  LOCAL prop := JOIN(agg, aggc,
             LEFT.wi_name=RIGHT.wi_name AND LEFT.pivot=RIGHT.pivot,
             TRANSFORM(r, SELF.Prop:=LEFT.Cnt/RIGHT.Tcnt, SELF:=LEFT),
             HASH);
  // Compute 1-gini coefficient for each node for each field for each value
  LOCAL rslt := TABLE(prop,
                      {wi_name, pivot, TotalCnt:=SUM(GROUP,Cnt),
                       Gini:=1-SUM(GROUP, Prop*Prop)},
                      wi_name, pivot);
  RETURN rslt;
ENDMACRO;
