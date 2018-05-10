/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems.  All rights reserved.
############################################################################## */
/**
  * Macro to convert a NumericField formatted, cell-based dataset to a Record formatted
  * dataset.  Typically used to return converted NumericField data back to
  * its original layout.
  *
  * <p>Note that as a Macro, nothing is returned, but new attributes are created
  * in-line for use in subsequent definitions.

  * <p>In the simplest case, the assumption is that the field order of the
  * resulting table is in line with the field number in the input
  * dataset, with the ID field as the first field.
  * <p>For example:
  * <pre>
  *   myRec := RECORD
  *     UNSIGNED recordId;
  *     REAL height;
  *     REAL weight;
  *   END;
  *   Value of NumericField records with field number = 1 would go to height.
  *   Value of NumericField records with field number = 2 would go to weight.
  *   The id field of the NumericField record would be mapped to the recordId
  *   field of the result.</pre>
  *
  * <p>If the field orders have been changed (e.g. by customizing the ToField
  * process, a field-mapping should be specified (See dMap below).
  *
  * Usage Examples:
  * <pre>
  *  ML.FromField(myNFData, myRecordLayout, myRecordData);
  *  // Datamap to reorder the weight and height fields in the example above
  *  dataMap := DATASET([{'weight', '1'},
                         {'height', '2'}], Types.Field_Mapping);
  *  ML.FromField(nyNFData, myRecordLayout, myRecordData, dataMap);</pre>
  *
  * @param dIn The name of the input dataset in NumericField format.
  * @param lOut The name of the layout record defining the records of the
  *             result dataset.
  * @param dOut The name of the result dataset.
  * @param dMap [OPTIONAL] A Field_Mapping dataset as produced by ToField
  *             that describes the mapping between field name and field number.
  *             The format of this map is defined by Types.Field_Mapping.
  * @return Nothing. The MACRO creates new attributes in-line as described above.
  * @see Types.NumericField
  * @see Types.Field_Mapping
  * @see ToField
  */
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