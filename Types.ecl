// Core types defined
EXPORT Types := MODULE
// The t_RecordID and t_FieldNumber are native nominal types of the ML
// libraries and they currently allow for 2**64 rows with 2**32
// features.
//
// If your needs are lower, then making these two smaller
// will improve performance. In particular an unsigned4 for t_RecordID
// supports 2**32 (more than 4 billion) rows and an unsigned2 for
// t_FieldNumber allows 64K features.
//
// Some ML modules will use dense matrix operations form PBblas and
// support only 4 billion (2**32) rows.
//
// The structures are also used for the myriad interface support.
// The notion is to support a myriad of small problems that need the
// steps applied.  Sort of a logical Single Instruction Multiple Data
// parallel machine approach.  The work_item is used to group the
// problem data.  If you have just one problem, the field should be
// set to some constant like 0 or 1.
//
  EXPORT t_RecordID := UNSIGNED8;
  EXPORT t_FieldNumber := UNSIGNED4;
  EXPORT t_FieldReal := REAL8;
  EXPORT t_FieldSign := INTEGER1;
  EXPORT t_Discrete := INTEGER4;
  EXPORT t_Item := UNSIGNED4; // Currently allows up to 4B different elements
  EXPORT t_Count := t_RecordID; // Possible to count every record
  EXPORT t_Work_Item := UNSIGNED2;  //TODO: change to be PBblas.Types.work_item_t

  // Base record for Numeric and Discrete Fields
  EXPORT AnyField     := RECORD
    t_Work_Item wi; // Work-item id
    t_RecordID id;  // Observation identifier (i.e. row id for X and Y) -- 1 based
    t_FieldNumber number; // Feature number (i.e. column number) -- 1 based
  END;

  // Numeric Field -- used to hold REAL values
  EXPORT NumericField := RECORD(AnyField)
    t_FieldReal value;
  END;

  // DiscreteField -- used to hold INTEGER values
  EXPORT DiscreteField := RECORD(AnyField)
    t_Discrete value;
  END;

  // Generic Layout describing the model 'learned' by a Machine Learning algorithm.
  EXPORT Layout_Model := RECORD
    t_Work_Item wi;       // Work-item of the model
    t_RecordID  id;       // Identifies the component type within the model
    t_FieldNumber number; // meaning varies by ID
    t_FieldReal value;    // The model parameter value
  END;

  // Classification definitions
  EXPORT Classify_Result := RECORD(DiscreteField)
    REAL8 conf;  // Confidence - high is good
  END;
  EXPORT l_result := Classify_Result : DEPRECATED('Use Classify_Result');

  EXPORT Confusion_Detail := RECORD
    t_work_item wi;
    t_FieldNumber classifier;   // Dependent column identifier
    t_Discrete actual_class;
    t_Discrete predict_class;
    UNSIGNED4 occurs;
    BOOLEAN correct;
  END;

  // generic items, used in association mining
  EXPORT ItemElement := RECORD
    t_Work_Item wi;
    t_Item value;
    t_RecordId id;
  END;

  // Decision Trees and Random Forest basics
  EXPORT t_node  := INTEGER4;   // Node Identifier Number in Decision Trees and Random Forest
  EXPORT t_level := UNSIGNED2;  // Tree Level Number
  EXPORT NodeID  := RECORD
    t_Work_Item wi;
    t_node  node_id;
    t_level level;
  END;
END;
