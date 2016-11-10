//IMPORT $.Types AS Types;
//---------------------------------------------------------------------------
// Macro takes a matrix dataset, with each row contianing an ID and one or
// more axis fields containing numeric values, and expands it into the
// NumericField format used by ML.
//
//   dIn       : The name of the input dataset
//   dOut      : The name of the resulting dataset
//   idfield   : [OPTIONAL] The name of the field that contains the UID for
//               each row.  If omitted, it is assumed to be the first field.
//   wifield   : [OPTIOPNAL] The name of the field that contains the
//               work item value.  A constant is used if the field name
//               is not supplied.
//   wivalue   : [OPTIONAL} The constant value to use for work item.
//               The value 1 is used if not supplied.
//   datafields: [OPTIONAL] A STRING contianing a comma-delimited list of the
//               fields to be treated as axes.  If omitted, all numeric
//               fields that are not the UID will be treated as axes.
//               NOTE: idfield defaults to the first field in the table, so
//               if that field is specified as an axis field, then the user
//               should be sure to specify a value in the idfield param.
//
//  Along with creating the NumericField table, this macro produces two
//  simple functions to assist the user in mapping the field names to their
//  corresponding numbers.  These are "STRING dOut_ToName(UNSIGNED)" and
//  "UNSIGNED dOut_ToNumber(STRING)", where the "dOut" portion of the function
//  name is the name passed into that parameter of the macro.
//
//  The macro also produces a mapping table named "dOut_Map", again where
//  "dOut" refers to the parameter, that contains a table of the field
//  mappings
//
//  Examples:
//    ML.ToField(dOrig,dMatrix);
//    ML.ToField(dOrig,dMatrix,myid,'field5,field7,field10');
//    dMatrix_ToName(2);  // returns 'field7'
//    dMatrix_ToNumber('field10'); // returns 3
//    dMatrix_Map; // returns the mapping table of field name to number
//---------------------------------------------------------------------------
EXPORT ToField(dIn,dOut,idfield='', wifield='', wivalue='',datafields=''):=MACRO
  LOADXML('<xml/>');
  // Variable to contain the name if the field that maps to "wi", or the value
  #DECLARE(use_for_wi);
  #IF(#TEXT(wivalue) = '')
    #SET(use_for_wi, 1);
  #ELSE
    #SET(use_for_wi, #TEXT(wivalue));
  #END
  // Variable to contain the name of the field that maps to "id"
  #DECLARE(foundidfield); #SET(foundidfield,#TEXT(idfield));
  // Contains a comma-delimited list of the fields that will be used as axes,
  // beginning with "COUNTER" so it can be #EXPANDED into a CHOOSE call
  // during normalization
  #DECLARE(normlist); #SET(normlist,'COUNTER');
  // Count of the fields that become axes
  #DECLARE(iNumberOfFields); #SET(iNumberOfFields,0);
  // A list of every field in the original table and the field number (or "ID")
  // to which it is mapped in the output.  "NA" indicates that the field was
  // not mapped.  The string is formatted so it can be easily #EXPANDED into
  // the data portion of a DATASET assignment.
  #DECLARE(mapping); #SET(mapping,'');
  // Variables to contain the definitions of the ToName and ToNumber functions
  #DECLARE(toname); #SET(toname,'STRING '+#TEXT(dOut)+'_ToName(UNSIGNED i):=MAP(');
  #DECLARE(tonumber); #SET(tonumber,'UNSIGNED '+#TEXT(dOut)+'_ToNumber(STRING s):=MAP(');
  // Loop through the layout of the input table to pick the fields and
  // produce the mapping
  #DECLARE(iPivotLoop); #SET(iPivotLoop,0);
  #EXPORTXML(fields,RECORDOF(dIn));
  #FOR(fields)
    #FOR(Field)
      #IF(%'foundidfield'%='' AND %iPivotLoop%=0)
        #SET(foundidfield,%'{@label}'%);
        #APPEND(mapping,',{\''+%'{@label}'%+'\',\'ID\'}')
      #ELSE
        #IF(%'{@label}'%=#TEXT(idfield))
          #APPEND(mapping,',{\''+%'{@label}'%+'\',\'ID\'}')
        #ELSEIF(%'{@label}'%=#TEXT(wifield))
          #SET(use_for_wi, 'LEFT.' + %'{@label}'%);
          #APPEND(mapping,',{\''+%'{@label}'%+'\',\'WI\'}')
        #ELSE
          #IF(REGEXREPLACE('[^a-z]',%'{@type}'%,'') IN ['unsigned','integer','real','decimal','udecimal'] #IF(#TEXT(datafields)!='') AND REGEXFIND('\\s*,\\s*'+%'{@label}'%+',',','+datafields+',',NOCASE) #END)
            #APPEND(normlist,',(Types.t_FieldReal)LEFT.'+%'{@label}'%)
            #SET(iNumberOfFields,%iNumberOfFields%+1)
            #APPEND(mapping,',{\''+%'{@label}'%+'\',\''+%'iNumberOfFields'%+'\'}')
            #APPEND(toname,'i='+%'iNumberOfFields'%+'=>\''+%'{@label}'%+'\',')
            #APPEND(tonumber,'s=\''+%'{@label}'%+'\'=>'+%'iNumberOfFields'%+',')
          #ELSE
            #APPEND(mapping,',{\''+%'{@label}'%+'\',\'NA\'}')
          #END
        #END
      #END
      #SET(iPivotLoop,%iPivotLoop%+1);
    #END
  #END
  // Finalize and #EXPAND the mapping functions
  #APPEND(toname,'\'\');')
  #EXPAND(%'toname'%)
  #APPEND(tonumber,'0);')
  #EXPAND(%'tonumber'%)
  // Produce the output, with one row for every id/axis combination.
  dOut:=NORMALIZE(dIn,%iNumberOfFields%,TRANSFORM(Types.NumericField,
                  SELF.wi:=#EXPAND(%'use_for_wi'%),
                  SELF.id:=LEFT.#EXPAND(%'foundidfield'%),
                  SELF.number:=COUNTER,
                  SELF.value:=CHOOSE(#EXPAND(%'normlist'%))));
  // Produce the mapping reference table
  #EXPAND(#TEXT(dOut)+'_Map:=DATASET(['+%'mapping'%[2..]+'],{STRING orig_name;STRING assigned_name;})');
ENDMACRO;