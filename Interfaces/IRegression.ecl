/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2016 HPCC Systems.  All rights reserved.
############################################################################## */
IMPORT $.^ as Core;
IMPORT Core.Types;

//IMPORT PBblas.Types AS PBBTypes;
AnyField     := Types.AnyField;
NumericField := Types.NumericField;
Layout_Model := Types.Layout_Model;
t_work_item  := Types.t_work_item;
t_RecordID   := Types.t_RecordID;
t_FieldNumber := Types.t_FieldNumber;
t_FieldReal   := Types.t_FieldReal;
null_model := DATASET([], Layout_Model);
empty_data := DATASET([], NumericField);

/**
  * ***DEPRECATED***
  * Interface Definition for Regression Modules (version 1).
  * This interface is being deprecated and should not be used for
  * new bundles or bundles undergoing substantial revision.
  * Please use IRegression2 going forward.
  *
  * Regression learns a function that maps a set of input data
  * to one or more output variables.  The resulting learned function is
  * known as the model.  That model can then be used repetitively to predict
  * (i.e. estimate) the output value(s) based on new input data.
  *
  * @param X The independent data in DATASET(NumericField) format.
  *          Each statistical unit (e.g. record) is identified by
  *          'id', and each feature is identified by field number (i.e.
  *          'number').
  *
  * @param Y The dependent variable(s) in DATASET(NumericField) format.
  *          Each statistical unit (e.g. record) is identified by
  *          'id', and each feature is identified by field number (i.e.
  *          'number').
  *
  */
EXPORT IRegression(DATASET(NumericField) X=empty_data,
                   DATASET(NumericField) Y=empty_data) := MODULE, VIRTUAL
  /**
    * Calculate and return the 'learned' model.
    *
    * The model may be persisted and later used to make predictions
    * using 'Predict' below.
    *
    * @return DATASET(LayoutModel) describing the learned model parameters.
    */
  EXPORT DATASET(Layout_Model) GetModel;
  /**
    * Predict the output variable(s) based on a previously learned model.
    *
    * @param newX DATASET(NumericField) containing the X values to b predicted.
    * @return DATASET(NumericField) containing one entry per observation (i.e. id)
    *                  in newX.  This represents the predicted values for Y.
    *
    */
  EXPORT DATASET(NumericField) Predict(DATASET(NumericField) newX,
                                       DATASET(Layout_Model) model);

END;
