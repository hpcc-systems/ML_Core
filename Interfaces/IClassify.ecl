IMPORT $.^ AS ML_Core;
IMPORT $.^.Types AS Types;

/**
 * Interface definition for Classification.  Actual implementation
 * modules will probably take parameters.
 */
EXPORT IClassify := MODULE, VIRTUAL
  /**
   * Calculate the model to fit the observation data to the observed
   * classes.
   * @param observations the observed explanatory values
   * @param classifications the observed classification used to build
   * the model
   * @return the encoded model
   */
  EXPORT DATASET(Types.Layout_Model)
        GetModel(DATASET(Types.NumericField) observations,
                 DATASET(Types.DiscreteField) classifications);
  /**
   * Classify the observations using a model.
   * @param model The model, which must be produced by a corresponding
   * getModel function.
   * @param new_observations observations to be classified
   * @return Classification with a confidence value
   */
  EXPORT DATASET(Types.Classify_Result)
        Classify(DATASET(Types.Layout_Model) model,
                 DATASET(Types.NumericField) new_observations);
  /**
   * Report the confusion matrix for the classifier and training data.
   * @param model the encoded model
   * @param observations the explanatory values.
   * @param classifications the classifications associated with the
   * observations
   * @return the confusion matrix showing correct and incorrect
   * results
   */
  EXPORT DATASET(Types.Confusion_Detail)
        Report(DATASET(Types.Layout_Model) model,
               DATASET(Types.NumericField) observations,
               DATASET(Types.DiscreteField) classifications);
END;
