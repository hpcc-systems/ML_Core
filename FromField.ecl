//---------------------------------------------------------------------------
// Macro to reconstitute an original matrix from a NumericField-formatted
// dataset.  In the simplest case, the assumption is that the field order
// of the resulting table is in line with the field numbers in the input
// dataset, with the ID field as the first field.  If a field mapping is
// specified, this order can be re-arranged.
//   dIn  : The name of the input dataset in NumericField format
//   lOut : The name of the resulting layout the data should be in
//   dOut : The name of the resulting dataset
//   dMap : [OPTIONAL] If the user customized the fields used in the ToField
//          process, they should include the mapping table that was created
//          automatically by ToField here so the fields map back properly.
//          This will be named NF_map, where NF is the name of the
//          NumericField table that was created by ToField.
//  Examples (used to reconstitute the ToField examples):
//    ML.FromField(dMatrix,lOrig,dResults);
//    ML.FromField(dMatrix,lOrig,dResults,dOrigData_Map);
//
// IMPORTANT NOTE: If fields in lOut were disregarded by the ToField macro
// during the creation of the NumericField table, those fields WILL NOT be
// reconstituted by this macro.  They will be left blank or zero.
//---------------------------------------------------------------------------
EXPORT FromField(dIn,lOut,dOut,dMap=''):=MACRO
  LOADXML('<xml/>');
  // If a mapping table was specified, we need to join it to the input data
  // to marry the field number to the field name.
  #UNIQUENAME(id)
  #UNIQUENAME(wi)
  #UNIQUENAME(dInPrep)
  #IF(#TEXT(dMap)='')
    %dInPrep%:=TABLE(dIn,{UNSIGNED %id%:=id;UNSIGNED %wi%:=wi; dIn;});
    // Variable to keep track of which field number we are on
    #DECLARE(iUnPivotLoop) #SET(iUnPivotLoop,0)
  #ELSE
    #UNIQUENAME(dTmp)
    %dTmp%:=JOIN(dIn,dMap((UNSIGNED)assigned_name>0),
                LEFT.number=(UNSIGNED)RIGHT.assigned_name,
                TRANSFORM({UNSIGNED %id%;UNSIGNED %wi%;RECORDOF(dIn) OR RECORDOF(dMap);},
                          SELF.%id%:=LEFT.id;
                          SELF.%wi%:=LEFT.wi;
                          SELF:=LEFT;SELF:=RIGHT;),
                LOOKUP,LEFT OUTER);
    %dInPrep%:=%dTmp%+PROJECT(DEDUP(dIn,id),
                              TRANSFORM(RECORDOF(%dTmp%),
                              SELF.%id%:=LEFT.id;
                              SELF.%wi%:=LEFT.wi;
                              SELF.orig_name:=dMap(assigned_name='ID')[1].orig_name;
                              SELF.value:=LEFT.id;
                              SELF:=LEFT;SELF:=[]))
                     +PROJECT(DEDUP(dIn,id),
                              TRANSFORM(RECORDOF(%dTmp%),
                              SELF.%id%:=LEFT.id;
                              SELF.%wi%:=LEFT.wi;
                              SELF.orig_name:=dMap(assigned_name='WI')[1].orig_name;
                              SELF.value:=LEFT.wi;
                              SELF:=LEFT;SELF:=[]));;
  #END
  // Variable to hold a string that will #EXPAND to a set of field assignments
  // used when DENORMALIZE is called.
  #DECLARE(assignments) #SET(assignments,'')
  #DECLARE(rid)
  #EXPORTXML(fields,lOut)
  #FOR(fields)
    #FOR(Field)
      #IF(REGEXREPLACE('[^a-z]',%'{@type}'%,'') IN ['unsigned','integer','real','decimal','udecimal'])
        #IF(#TEXT(dMap)='')
          #IF(%iUnPivotLoop%=0)
            #SET(assignments,'SELF.'+%'{@label}'%+':=LEFT.'+%'id'%+';');
          #ELSE
            #APPEND(assignments,'SELF.'+%'{@label}'%+':=LEFT.'+%'{@label}'%+'+IF(RIGHT.number='+%'iUnPivotLoop'%+',RIGHT.value,0);')
          #END
          #SET(iUnPivotLoop,%iUnPivotLoop%+1)
        #ELSE
          #APPEND(assignments,'SELF.'+%'{@label}'%+':=LEFT.'+%'{@label}'%+'+IF(RIGHT.orig_name=\''+%'{@label}'%+'\',RIGHT.value,0);')
        #END
      #END
    #END
  #END
  // Denormalize the data using the #EXPAND string constructed above.
  #UNIQUENAME(dIDs)
  %dIDs%:=PROJECT(TABLE(%dInPrep%,{TYPEOF(%dInPrep%.id) %id%:=id},id,MERGE),TRANSFORM({lOut;TYPEOF(%dInPrep%.id) %id%;},SELF:=LEFT;SELF:=[];));
  dOut:=PROJECT(DENORMALIZE(%dIDs%,%dInPrep%,LEFT.%id%=RIGHT.%id%,TRANSFORM(RECORDOF(%dIDs%),#EXPAND(%'assignments'%)SELF:=LEFT;)),lOut);
ENDMACRO;