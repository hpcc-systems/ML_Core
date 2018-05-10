IMPORT $.^ AS ML_Core;
IMPORT ML_Core.Types AS Types;

Layout_Model2 := Types.Layout_Model2;
Classify_Result := Types.Classify_Result;
NumericField := Types.NumericField;
DiscreteField := Types.DiscreteField;
Confusion_Detail := Types.Confusion_Detail;
Classification_Accuracy := Types.Classification_Accuracy;
Class_Accuracy := Types.Class_Accuracy;

/**
  * Interface definition for Classification (Version 2).
  * Classification learns a function that maps a set of input data
  * to one or more output class-label (i.e. Discrete) variables.
  * The resulting learned function is known as the model.
  * That model can then be used repetitively to predict the class(es)
  * for each sample when presented with new input data.
  * Actual implementation modules will probably take configuration
  * parameters to control the classification process.
  * The Classification modules also expose attributes for assessing
  * the effectiveness of the classification.
  */
EXPORT IClassify2 := MODULE, VIRTUAL
  /**
    * Calculate the model to fit the independent data to the observed
    * classes (i.e. dependent data).
    * @param indepenedents The observed independent (explanatory) values.
    * @param dependents The observed dependent(class label) values.
    * @return The encoded model.
    * @see Types.Layout_Model2
    * @see Types.NumericField
    * @see Types.DiscreteField
    */
  EXPORT DATASET(Layout_Model2) GetModel(DATASET(NumericField) independents,
                                         DATASET(DiscreteField) dependents);
  /**
    * Classify the observations using a model.
    * @param model The model, which must be produced by a corresponding
    * getModel function.
    * @param observations New observations (independent data) to be classified.
    * @return Predicted class values.
    *
    */
  EXPORT DATASET(DiscreteField) Classify(DATASET(Layout_Model2) model,
                                         DATASET(NumericField) observations);
  /**
    * Return accuracy metrics for the given set of test data
    * <p>This is equivalent to calling Predict followed by
    * Analysis.Classification.Accuracy(...).
    *
    * <p>Provides accuracy statistics as follows:<ul>
    * <li>errCount -- The number of misclassified samples.</li>
    * <li>errPct -- The percentage of samples that were misclasified (0.0 - 1.0).</li>
    * <li>RawAccuracy -- The percentage of samples properly classified (0.0 - 1.0).</li>
    * <li>PoD -- Power of Discrimination.  Indicates how this classification performed
    *           relative to a random guess of class.  Zero or negative indicates that
    *           the classification was no better than a random guess.  1.0 indicates a
    *           perfect classification.  For example if there are two equiprobable classes,
    *           then a random guess would be right about 50% of the time.  If this
    *           classification had a Raw Accuracy of 75%, then its PoD would be .5
    *           (half way between a random guess and perfection).</li>
    * <li>PoDE -- Power of Discrimination Extended.  Indicates how this classification
    *           performed relative to guessing the most frequent class (i.e. the trivial
    *           solution).  Zero or negative indicates that this classification is no
    *           better than the trivial solution.  1.0 indicates perfect classification.
    *           For example, if 95% of the samples were of class 1, then the trivial
    *           solution would be right 95% of the time.  If this classification had a
    *           raw accuracy of 97.5%, its PoDE would be .5 (i.e. half way between
    *           trivial solution and perfection).</li>
    * <p>Normally, this should be called using data samples that were not included in the
    * training set.  In that case, these statistics are considered Out-of-Sample error
    * statistics.  If it is called with the X and Y from the training set, it provides
    * In-Sample error statistics, which should never be used to rate the classification model.
    *
    *
    * @param model The encoded model as returned from GetModel.
    * @param actuals The actual class values associated with the observations.
    * @param observations The independent (explanatory) values on which to base the test.
    * @return DATSET(Classification_Accuracy), one record per work-item.
    * @see Types.Classification_Accuracy
    *
    */
  EXPORT DATASET(Classification_Accuracy) Accuracy(DATASET(Layout_Model2) model,
                                                   DATASET(DiscreteField) actuals, DATASET(NumericField) observations
                                                   ) := FUNCTION
    predicted := Classify(model, observations);
    RETURN ML_Core.Analysis.Classification.Accuracy(predicted, actuals);
  END;
  /**
    * Return class-level accuracy by class metrics for the given 
    * set of test data.
    * <p>This is equivalent to calling Predict followed by
    * Analysis.Classification.AccuracyByClass(...).
    *
    * @param model The encoded model as returned from GetModel.
    * @param actuals The actual class values associated with the observations.
    * @param observations The independent (explanatory) values on which to base the test
    * @return DATASET(Class_Accuracy), one record per work-item per class.
    * @see Types.Class_Accuracy.
    *
    */
  EXPORT DATASET(Class_Accuracy) AccuracyByClass(DATASET(Layout_Model2) model,
                                                   DATASET(DiscreteField) actuals,
                                                   DATASET(NumericField) observations
                                                   ) := FUNCTION
    predicted := Classify(model, observations);
    RETURN ML_Core.Analysis.Classification.AccuracyByClass(predicted, actuals);
  END;
  /**
    * Return the confusion matrix for a set of test data.
    * This is equivalent to calling Predict follwed by
    * Analysis.Classification.ConfusionMatrix(...).
    * <p>The confusion matrix indicates the number of datapoints that were classified correctly or incorrectly
    * for each class label.
    * <p>The matrix is provided as a matrix of size numClasses x numClasses with fields as follows:<ul>
    *   <li>'wi' -- The work item id</li>
    *   <li>'pred' -- the predicted class label (from Classify).</li>
    *   <li>'actual' -- the actual (target) class label.</li>
    *   <li>'samples' -- the count of samples that were predicted as 'pred', but should have been 'actual'.</li>
    *   <li>'totSamples' -- the total number of samples that were predicted as 'pred'.</li>
    *   <li>'pctSamples' -- the percentage of all samples that were predicted as 'pred', that should
    *                have been 'actual' (i.e. samples / totSamples)</li></ul>
    *
    * <p>This is a useful tool for understanding how the algorithm achieved the overall accuracy.  For example:
    * were the common classes mostly correct, while less common classes often misclassified?  Which
    * classes were most often confused?
    *
    * This should be called with test data that is independent of the training data in order to understand
    * the out-of-sample (i.e. generalization) performance.
    *
    * @param model The encoded model as returned from GetModel.
    * @param actuals The actual class values.
    * @param observations The independent (explanatory) values.
    * @return DATASET(Confusion_Detail), one record per cell of the confusion matrix.
    * @see Types.Confusion_Detail.
    */
  EXPORT DATASET(Confusion_Detail) ConfusionMatrix(DATASET(Layout_Model2) model,
                                                   DATASET(DiscreteField) actuals, DATASET(NumericField) observations
                                                   ) := FUNCTION 
    predicted := Classify(model, observations);
    RETURN ML_Core.Analysis.Classification.ConfusionMatrix(predicted, actuals);
  END;
END;
