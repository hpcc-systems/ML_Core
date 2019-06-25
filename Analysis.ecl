/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */
IMPORT $ AS ML_Core;
IMPORT ML_Core.Types;

DiscreteField := Types.DiscreteField;
NumericField := Types.NumericField;
t_Work_Item := Types.t_Work_Item;
t_RecordId := Types.t_RecordId;
t_FieldNumber := Types.t_FieldNumber;
t_FieldReal := Types.t_FieldReal;
t_Discrete := Types.t_Discrete;
Class_Stats := Types.Class_Stats;
Confusion_Detail := Types.Confusion_Detail;
Classification_Accuracy := Types.Classification_Accuracy; // Return structure for
                                                          // Classification.Accuracy
Class_Accuracy := Types.Class_Accuracy; // Return structure for Classification.AccuracyByClass
Regression_Accuracy := Types.Regression_Accuracy; // Return structure for Regression.Accuracy
Contingency_Table := Types.Contingency_Table; // Return structure for FeatureSelection.Contingency
Chi2_Result : Types.Chi2_Result; // Return structure for FeatureSelection.Chi2

/**
  * Analyze and assess the effectiveness of a Machine
  * Learning model.
  * <p>Sub-modules provide support for both Classification and Regression.
  *
  * <p>Each of the functions in this module support multi-work-item (i.e. Myriad interface) data, as well as
  * multi-variate data (supported by some ML bundles).  The number field, which is usually
  * = 1 for uni-variate data is used to distinguish multiple regressors in the case of multi-
  * variate models.
  *
  **/
EXPORT Analysis := MODULE
  /**
    * This sub-module provides functions for analyzing and assessing the effectiveness of
    * an ML Classification model.  It can be used with any ML Bundle that supports classification.
    */
  EXPORT Classification := MODULE
    /**
      * Given a set of expected dependent values, assess the number and percentage of records that
      * were of each class.
      *
      * @param actual The set of training-data or test-data dependent values in DATASET(DiscreteField)
      *               format.
      * @return DATASET(Class_Stats), one record per work-item, per classifier (i.e. number field) per
      *         class.
      * @see ML_Core.Types.Class_Stats
      **/
    EXPORT DATASET(Class_Stats) ClassStats(DATASET(DiscreteField) actual) := FUNCTION
      // Returns for each class: label, count, pct
      recStats := TABLE(actual, {wi, number, cnt := COUNT(GROUP)}, wi, number);
      cStats := TABLE(actual, {wi, number, value, cnt := COUNT(GROUP)}, wi, number, value);
      outStats := JOIN(cStats, recStats, LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                      TRANSFORM(Class_Stats,
                                  SELF.classifier := LEFT.number,
                                  SELF.class := LEFT.value,
                                  SELF.classCount := LEFT.cnt,
                                  SELF.classPct := LEFT.cnt / RIGHT.cnt,
                                  SELF := LEFT), LOOKUP);
      RETURN outStats;
    END; // ClassStats
    // Function to compare predicted and actual values and include them in a record set containing both,
    // as well as a 'correct' indicator, which is TRUE whenever the two match.
    SHARED CompareClasses(DATASET(DiscreteField) predicted, DATASET(DiscreteField) actual) := FUNCTION
      // Distribute predicted and actual by HASH32(wi, id)
      predD := DISTRIBUTE(predicted, HASH32(wi, id));
      actD := DISTRIBUTE(actual, HASH32(wi, id));
      cmp := JOIN(predD, actD, LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number AND LEFT.id = RIGHT.id,
                  TRANSFORM({t_Work_Item wi, t_FieldNumber number, t_Discrete pred, t_discrete actual, BOOLEAN correct},
                              SELF.pred := LEFT.value,
                              SELF.actual := RIGHT.value,
                              SELF.correct := LEFT.value = RIGHT.value,
                              SELF := LEFT), LOCAL);
      // cmp is distributed by HASH32(wi, id)
      RETURN cmp;
    END; // CompareClasses
    /**
      * Returns the Confusion Matrix, counting the number of cases for each combination of predicted Class and
      * actual Class.
      *
      * @param predicted The predicted values for each id in DATASET(DiscreteField) format.
      * @param actual The actual (i.e. expected) values for each id in DATASET(DiscreteField) format.
      * @return DATASET(Confusion_Detail).  One record for each combination of work-item, number (i.e. classifier),
      *         predicted class, and actual class.
      * @see ML_Core.Types.Confusion_Detail
      *
      **/
    EXPORT DATASET(Confusion_Detail) ConfusionMatrix(DATASET(DiscreteField) predicted, DATASET(DiscreteField) actual) := FUNCTION
      cmp := CompareClasses(predicted, actual);
      // Count the number of samples that were actually of each class
      actualClassTots := TABLE(cmp, {wi, number, actual, tot := COUNT(GROUP)}, wi, number, actual);
      // Count the number of samples that were predicted for each class
      predClassTots := TABLE(cmp, {wi, number, pred, tot := COUNT(GROUP)}, wi, number, pred);
      // Count the number of samples for each combination of actual and predicted
      cm0 := TABLE(cmp, {wi, t_FieldNumber classifier := number,
                          t_Discrete actual_class := actual, t_Discrete predict_class := pred,
                          UNSIGNED4 occurs := COUNT(GROUP), BOOLEAN correct := pred = actual}, wi, number, actual, pred);
      // Now calculate the proportions (of both actual and predicted values for each combination)
      cm1 := JOIN(cm0, actualClassTots, LEFT.wi = RIGHT.wi AND LEFT.classifier = RIGHT.number
                      AND LEFT.actual_class = RIGHT.actual,
                    TRANSFORM({RECORDOF(LEFT), t_FieldReal pctActual},
                                SELF.pctActual := LEFT.occurs / RIGHT.tot,
                                SELF := LEFT), LOOKUP);
      cm2 := JOIN(cm1, predClassTots, LEFT.wi = RIGHT.wi AND LEFT.classifier = RIGHT.number
                      AND LEFT.predict_class = RIGHT.pred,
                    TRANSFORM({RECORDOF(LEFT), t_FieldReal pctPred},
                                SELF.pctPred := LEFT.occurs / RIGHT.tot,
                                SELF := LEFT), LOOKUP);
      cm := PROJECT(cm2, Confusion_Detail);
      RETURN cm;
    END; // ConfusionMatrix
    /**
      * Assess the overall accuracy of the classification predictions.
      *
      * <p>ML_Core.Types.Classification_Accuracy provides a detailed description of the return values. 
      *
      * @param predicted The predicted values for each id in DATASET(DiscreteField) format.
      * @param actual The actual (i.e. expected) values for each id in DATASET(DiscreteField) format.
      * @return DATASET(Classification_Accuracy).  One record for each combination of work-item, and
      *         number (i.e. classifier).
      * @see ML_Core.Types.Classification_Accuracy
      *
      **/
    EXPORT DATASET(Classification_Accuracy) Accuracy(DATASET(DiscreteField) predicted, DATASET(DiscreteField) actual) := FUNCTION
      // Returns Raw, PoD, PoDE
      cStats := ClassStats(actual);
      numClasses := TABLE(cStats, {wi, classifier, UNSIGNED4 num_classes := COUNT(GROUP)}, wi, classifier);
      mostCommon0 := SORT(cStats, wi, classifier, -classCount);
      mostCommon := DEDUP(mostCommon0, wi, classifier);
      globStats := JOIN(numClasses, mostCommon, LEFT.wi = RIGHT.wi AND LEFT.classifier = RIGHT.classifier,
                        TRANSFORM({numClasses, UNSIGNED4 highestCnt},
                                  SELF.highestCnt := RIGHT.classCount,
                                  SELF := LEFT));
      cmp := CompareClasses(predicted, actual);
      cmpStats := TABLE(cmp, {wi, number, UNSIGNED4 corrCnt := COUNT(GROUP, correct), UNSIGNED4 totCnt := COUNT(GROUP)}, wi, number);
      outStats := JOIN(cmpStats, globStats, LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.classifier,
                        TRANSFORM(Classification_Accuracy,
                                   SELF.classifier := LEFT.number,
                                   SELF.errCnt := LEFT.totCnt - LEFT.corrCnt,
                                   SELF.recCnt := LEFT.totCnt,
                                   SELF.Raw_accuracy := LEFT.corrCnt / LEFT.totCnt,
                                   SELF.PoD := (LEFT.corrCnt -  LEFT.totCnt / RIGHT.num_classes) /
                                                  (LEFT.totCnt - LEFT.totCnt / RIGHT.num_classes),
                                   SELF.PoDE := (LEFT.corrCnt - RIGHT.highestCnt) /
                                                  (LEFT.totCnt - RIGHT.highestCnt),
                                   SELF := LEFT), LOOKUP);
      RETURN outStats;
    END; // Accuracy
    /**
      * Provides per class accuracy / relevance statistics (e.g. Precision / Recall,
      * False-positive Rate).
      * 
      * <p>ML_Core.Types.Class_Accuracy provides a detailed description of the return values. 
      *
      * @param predicted The predicted values for each id in DATASET(DiscreteField) format.
      * @param actual The actual (i.e. expected) values for each id in DATASET(DiscreteField) format.
      * @return DATASET(Class_Accuracy).  One record for each combination of work-item, number (i.e. classifier),
      *         and class.
      * @see ML_Core.Types.Class_Accuracy
      *
      **/
    EXPORT DATASET(Class_Accuracy) AccuracyByClass(DATASET(DiscreteField) predicted, DATASET(DiscreteField) actual) := FUNCTION
      // Returns Precision, Recall, False Positive Rate(FPR)
      allClasses0 := SORT(actual, wi, number, value);
      allClasses := DEDUP(actual, wi, number, value);
      cmp := CompareClasses(predicted, actual);
      // For each class, replicate all of the items not of that class so that we can analyze that class
      // with respect to its non-members (i.e. negatives).
      allClassPts := JOIN(cmp, allClasses, LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                          TRANSFORM({cmp, UNSIGNED class},
                                      SELF.class := RIGHT.value,
                                      SELF := LEFT), MANY, LOOKUP);
      allClassSumm := TABLE(allClassPts, {wi, number, class,
                             UNSIGNED4 precDenom := COUNT(GROUP, pred = class),
                             UNSIGNED4 TP := COUNT(GROUP, pred = class AND actual = class),
                             UNSIGNED4 FP := COUNT(GROUP, pred = class AND actual != class),
                             UNSIGNED4 recallDenom := COUNT(GROUP, actual = class),
                             UNSIGNED4 TN := COUNT(GROUP, actual != class AND pred != class),
                             UNSIGNED4 FN := COUNT(GROUP, actual = class AND pred != class),
                             }, wi, number, class);
      cStats := PROJECT(allClassSumm, TRANSFORM(Class_Accuracy,
                                            SELF.classifier := LEFT.number,
                                            SELF.precision := LEFT.TP / (LEFT.TP + LEFT.FP),
                                            SELF.recall := LEFT.TP / (LEFT.TP + LEFT.FN),
                                            SELF.FPR := LEFT.FP / (LEFT.FP + LEFT.TN),
                                            SELF := LEFT));
      RETURN cStats;
    END; // AccuracyByClass
  END; // Classification
  /**
    * This sub-module provides functions for analyzing and assessing the effectiveness of
    * an ML Regression model.  It can be used with any ML Bundle that supports regression.
    *
    */
  EXPORT Regression := MODULE
    /**
      * Assess the overall accuracy of the regression predictions.
      *
      * <p>ML_Core.Types.Regression_Accuracy provides a detailed description of the return values. 
      *
      * @param predicted The predicted values for each id in DATASET(DiscreteField) format.
      * @param actual The actual (i.e. expected) values for each id in DATASET(DiscreteField) format.
      * @return DATASET(Regression_Accuracy).  One record for each combination of work-item, and
      *         number (i.e. regressor).
      * @see ML_Core.Types.Regression_Accuracy
      *
      **/
    EXPORT DATASET(Regression_Accuracy) Accuracy(DATASET(NumericField) predicted, DATASET(NumericField) actual) := FUNCTION
      // Returns R-squared, MSE, RMSE
      meanAct := TABLE(actual, {wi, number, REAL mean := AVE(GROUP, value), cnt := COUNT(GROUP)}, wi, number);
      cmp := JOIN(actual, predicted, LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number AND LEFT.id = RIGHT.id,
                    TRANSFORM({t_Work_Item wi, t_FieldNumber number, t_FieldReal actual, t_FieldReal pred},
                      SELF.actual := LEFT.value,
                      SELF.pred := RIGHT.value,
                      SELF := LEFT));
      calc0 := JOIN(cmp, meanAct, LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                      TRANSFORM({cmp, REAL ts, REAL rs},
                        SELF.ts := POWER(LEFT.actual - RIGHT.mean, 2), // Total squared
                        SELF.rs := POWER(LEFT.actual - LEFT.pred, 2),  // Residual squared
                        SELF := LEFT), LOOKUP);
      // R2 := 1 - (Residual Sum of Squares / Total Sum of Squares)
      calc1 := TABLE(calc0, {wi, number, R2 := 1 - SUM(GROUP, rs) / SUM(GROUP, ts), RSS := SUM(GROUP, rs)}, wi, number);
      result := JOIN(calc1, meanAct, LEFT.wi = RIGHT.wi AND LEFT.number = RIGHT.number,
                      TRANSFORM(Regression_Accuracy,
                        SELF.MSE := LEFT.RSS / RIGHT.cnt,
                        SELF.RMSE := POWER(SELF.MSE, .5),
                        SELF.regressor := LEFT.number,
                        SELF := LEFT), LOOKUP);
      RETURN result;
    END; // Accuracy
  END; // Regression
  EXPORT FeatureSelection := MODULE
    /**
      * Contingency
      *
      * Provides the contingency table for each combination of feature and classifier. The
      * contingency table represents the number of samples present in the data for each
      * combination of sample category and feature category. Can only be used when both
      * classifier and feature are discrete.
      *
      * The sets provided need not be sample / feature sets. They can be any two discrete
      * fields whose contingency table is needed.
      *
      * @param samples The samples or dependent values in DATASET(DiscreteField) format
      * @param features The features or independent values in DATASET(DiscreteField) format
      * @return DATASET(Contingency_Table) The contingency table for each combination of
      *         classifier (sample) and feature, per work item
      * @see ML_Core.Types.Contingency_Table
      *
      */
    EXPORT DATASET(Contingency_Table) Contingency(DATASET(DiscreteField) samples, DATASET(DiscreteField) features) := FUNCTION
      // To obtain the contingency tables, the samples and features are first combined into a 
      // single table, with every feature mapped to every classifier
      combined := JOIN(samples, features,
                 LEFT.wi=RIGHT.wi and LEFT.id=RIGHT.id,
                 TRANSFORM({t_Work_Item wi, t_RecordId id, t_FieldNumber fnumber,
                            t_FieldNumber snumber, t_Discrete fclass, t_Discrete sclass},
                           SELF.wi := LEFT.wi,
                           SELF.id := LEFT.id,
                           SELF.fnumber := RIGHT.number,
                           SELF.snumber := LEFT.number,
                           SELF.fclass := RIGHT.value,
                           SELF.sclass := LEFT.value));
      // This combined data is then grouped to obtain the contingency tables
      result := TABLE(combined, {wi,fnumber,snumber,fclass,sclass,cnt:=COUNT(GROUP)},
                                wi,fnumber,snumber,fclass,sclass);
      RETURN result;
    END; //Contingency
    /**
      * Chi2
      *
      * Provides Chi2 coefficient and number of degrees of freedom for each combination
      * of feature and classifier.
      *
      * Chi squared test is a statistical measure that helps establish the dependence of
      * two categorical variables. In machine learning, it can be used to determine whether
      * a classifier is dependent on a certain feature, and thus helps in feature selection.
      * This test can only be used when both variables are categorical.
      *
      * @param samples The samples or dependent values in DATASET(DiscreteField) format
      * @param features The features or independent values in DATASET(DiscreteField) format
      * @return DATASET(Chi2_Result) Chi square values and degrees of freedom for each
      *         combination of feature and classifier, per work item.
      * @see ML_Core.Types.Chi2_Result
      *
      */
    EXPORT DATASET(Chi2_Result) Chi2(DATASET(DiscreteField) samples, DATASET(DiscreteField) features) := FUNCTION
      // Sums of rows
      featureSums := TABLE(ct, {wi,fnumber,snumber,fclass,cnt:=SUM(GROUP,cnt)},wi,fnumber,snumber,fclass);
      // Sums of columns
      sampleSums := TABLE(ct, {wi,fnumber,snumber,sclass,cnt:=SUM(GROUP,cnt)},wi,fnumber,snumber,sclass);
      // Total sum
      allSum := TABLE(ct, {wi,fnumber,snumber,cnt:=SUM(GROUP,cnt)},wi,fnumber,snumber);
      // The expected contingency table from the above sums (1)
      ex1 := JOIN(featureSums, sampleSums,
                  LEFT.wi=RIGHT.wi and LEFT.fnumber=RIGHT.fnumber and LEFT.snumber=RIGHT.snumber,
                  TRANSFORM({t_Work_Item wi, t_FieldNumber fnumber, t_FieldNumber snumber, 
                             t_Discrete fclass, t_Discrete sclass, REAL8 value},
                            SELF.wi := LEFT.wi,
                            SELF.value := LEFT.cnt * RIGHT.cnt,
                            SELF.fnumber := LEFT.fnumber,
                            SELF.snumber := LEFT.snumber,
                            SELF.fclass := LEFT.fclass,
                            SELF.sclass := RIGHT.sclass));
      // The expected contingency table from the above sums (2)
      ex2 := JOIN(ex1, allSum,
                  LEFT.wi=RIGHT.wi and LEFT.fnumber=RIGHT.fnumber and LEFT.snumber=RIGHT.snumber,
                  TRANSFORM(RECORDOF(ex1),
                            SELF.value := LEFT.value/RIGHT.cnt,
                            SELF := LEFT));
      // Degrees of freedom calculation dof = (ROWS - 1)*(COLS - 1)
      // Number of rows
      dof1 := TABLE(featureSums, {wi,fnumber,snumber,dof:=COUNT(GROUP)-1}, wi, fnumber,snumber);
      // Number of cols
      dof2 := TABLE(sampleSums, {wi,fnumber,snumber,dof:=COUNT(GROUP)-1}, wi, fnumber,snumber);
      // DOF
      dof3 := JOIN(dof1,dof2, 
                   LEFT.wi=RIGHT.wi and
                   LEFT.fnumber=RIGHT.fnumber and
                   LEFT.snumber=RIGHT.snumber,
                   TRANSFORM(RECORDOF(dof1),
                             SELF.dof := LEFT.dof*RIGHT.dof,
                             SELF := LEFT));
      // Chi square calculation from expected and observed contingency tables.
      // LEFT OUTER JOIN flag is used as the contingency table does not contain entries for
      // combinations where no samples are available. The expected contingency table contains
      // entries for all combinations of sample and feature classes, hence the OUTER condition
      // is used to produce entries for all combinations of sample and feature classes.
      chi2_1 := JOIN(ex2, ct,
                     LEFT.wi=RIGHT.wi and
                     LEFT.fnumber=RIGHT.fnumber and
                     LEFT.snumber=RIGHT.snumber and
                     LEFT.fclass=RIGHT.fclass and
                     LEFT.sclass=RIGHT.sclass,
                     TRANSFORM(RECORDOF(ex2),
                               SELF.value := POWER(RIGHT.value-LEFT.value,2)/LEFT.value,
                               SELF := LEFT), LEFT OUTER);
      // Group by wi, fnumber, snumner
      chi2_2 := TABLE(chi2_1, {wi,fnumber,snumber,x2:=SUM(GROUP,value)},wi,fnumber,snumber);
      // Combine with calculated dof
      result := JOIN(chi2_2, dof3, 
                     LEFT.wi=RIGHT.wi and LEFT.fnumber=RIGHT.fnumber and LEFT.snumber=RIGHT.snumber);
      RETURN result;
    END; //Chi2
  END; // FeatureSelection
END; // Analysis
