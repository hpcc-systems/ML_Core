/*#############################################################################
## HPCC SYSTEMS software Copyright (C) 2016 HPCC Systems. All rights reserved.
############################################################################## */
IMPORT $.^ as ML_Core;
IMPORT ML_Core.Types;

//IMPORT PBblas.Types AS PBBTypes;
AnyField     := Types.AnyField;
NumericField := Types.NumericField;
Layout_Model2 := Types.Layout_Model2;
Regression_Accuracy := Types.Regression_Accuracy;
t_work_item  := Types.t_work_item;
t_RecordID   := Types.t_RecordID;
t_FieldNumber := Types.t_FieldNumber;
t_FieldReal   := Types.t_FieldReal;
null_model := DATASET([], Layout_Model2);
empty_data := DATASET([], NumericField);

/**
  * Interface Definition for Regression Modules (Version 2).
  *
  * Regression learns a function that maps a set of input data
  * to one or more continuous output variables.  The resulting learned function is
  * known as the model.  That model can then be used repetitively to predict
  * (i.e. estimate) the output value(s) based on new input data.
  * Actual implementation modules will probably take configuration
  * parameters to control the regression process.
  * The regression modules also expose attributes for assessing the effectiveness
  * of the regression.
  *
  */
EXPORT IRegression2 := MODULE, VIRTUAL
  /**
    * Calculate and return the 'learned' model.
    *
    * <p>The model may be persisted and later used to make predictions
    * using 'Predict' below.
    *
    * @param independents The independent data in DATASET(NumericField) format.
    *          Each statistical unit (e.g. record) is identified by
    *          'id', and each feature is identified by field number (i.e.
    *          'number').
    * @param dependents The dependent variable(s) in DATASET(NumericField) format.
    *          Each statistical unit (e.g. record) is identified by
    *          'id', and each feature is identified by field number (i.e.
    *          'number').
    * @return The encoded model.
    * @see Types.NumericField
    * @see Types.Layout_Model2
    */
  EXPORT DATASET(Layout_Model2) GetModel(DATASET(NumericField) independents,
                   DATASET(NumericField) dependents);
  /**
    * Predict the output variable(s) based on a previously learned model
    *
    * @param independents the observations upon which to predict.
    * @return one entry per observation (i.e. id)
    *                  in observations.  This represents the predicted values for the dependent
    *                  variable(s).
    *
    */
  EXPORT DATASET(NumericField) Predict(DATASET(Layout_Model2) model, DATASET(NumericField) observations);

  /**
    * Assess the accuracy of a set of predictions.
    *
    * This is equivalent to calling predict and then Analysis.Regression.Accuracy.
    *
    * @param model The model as returned from GetModel
    * @param actuals The actual values of the dependent variable to compare with the predictions.
    * @param observations The independent data upon which the accuracy assessment is to be based.
    * @return Accuracy statistics (see Types.Regression_Accuracy for details)
    *
    */
  EXPORT DATASET(Regression_Accuracy) Accuracy(DATASET(Layout_Model2) model, DATASET(NumericField) actuals,
          DATASET(NumericField) observations) := FUNCTION
    predicted := Predict(model, observations);
    RETURN ML_Core.Analysis.Regression.Accuracy(predicted, actuals);
  END;
END;
