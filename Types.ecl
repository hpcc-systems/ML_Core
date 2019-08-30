/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */
//IMPORT $ AS ML_Core;
//NamingTree := ML_Core.NamingTree;

/**
  * This module provides the major data type definitions for use with the various
  * ML Bundles
  *
  */
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
// set to some positive constant like 1.
//
  EXPORT t_RecordID := UNSIGNED8;
  EXPORT t_FieldNumber := UNSIGNED4;
  EXPORT t_FieldReal := REAL8;
  EXPORT t_FieldSign := INTEGER1;
  EXPORT t_Discrete := INTEGER4;
  EXPORT t_Item := UNSIGNED4; // Currently allows up to 4B different elements
  EXPORT t_Count := t_RecordID; // Possible to count every record
  EXPORT t_Work_Item := UNSIGNED2;  //TODO: change to be PBblas.Types.work_item_t
  EXPORT t_index := UNSIGNED4;  // Type of each index value (see Layout_Model2)
  EXPORT t_indexes := SET OF t_index; // Definition of the indexes field for Layout_Model2

  // Base record for Numeric and Discrete Fields
  EXPORT AnyField     := RECORD
    t_Work_Item wi; // Work-item id
    t_RecordID id;  // Observation identifier (i.e. row id for X and Y) -- 1 based
    t_FieldNumber number; // Feature number (i.e. column number) -- 1 based
  END;

  /**
    * The NumericField layout defines a matrix of Real valued data-points.
    * It acts as the primary Dataset layout for interacting with most ML Functions.
    * Each record represents a single cell in a matrix.  It is most often used
    * to represent a set of data-samples or observations, with the 'id' field representing
    * the data-sample or observation, and the 'number' field representing the 
    * various fields within the observation.
    *
    * @field wi The work-item id, supporting the Myriad style interface.  This allows
    *           multiple independent matrixes to be contained within a single dataset,
    *           supporting independent ML activities to be processed in parallel.
    * @field id This field represents the row-number of this cell of the matrix.  It
    *           is also considered the record-id for observations / data-samples.
    * @field number This field represents the matrix column number for this cell.  It
    *               is also considered the field number of the observation
    * @field value The value of this cell in the matrix.
    *
    */
  EXPORT NumericField := RECORD(AnyField)
    t_FieldReal value;
  END;

  /**
    * The Discrete Field layout defines a matrix of Integer valued data-points.
    * It is similar to the NumericField layout above, except for only containing
    * discrete (integer) values.
    * It is typically used to convey the class-labels for classification algorithms.
    *
    * @field wi The work-item id, supporting the Myriad style interface.  This allows
    *           multiple independent matrixes to be contained within a single dataset,
    *           supporting independent ML activities to be processed in parallel.
    * @field id This field represents the row-number of this cell of the matrix.  It
    *           is also considered the record-id for observations / data-samples.
    * @field number This field represents the matrix column number for this cell.  It
    *               is also considered the field number of the observation
    * @field value The value of this cell in the matrix.
    *
    */
  EXPORT DiscreteField := RECORD(AnyField)
    t_Discrete value;
  END;

  /**
    * Layout for Model dataset (version 2)
    *
    * Generic Layout describing the model 'learned' by a Machine Learning algorithm.
    *
    * Models for all new ML bundles are stored in this format.
    * Some older bundles may still use the Layout_Model (version 1)
    * layout.
    *
    * Models are thought of as opaque data structures.  They are
    * not designed to be understandable except to the bundle that
    * produced them.  Most bundles contain mechanisms to extract
    * useful information from the model.
    *
    * This version of the model is based on a Naming-Tree paradigm.
    * This provides a flexible generic mechanism for storage and
    * manipulation of models.
    *
    * For bundle developers (or the curious), the file modelOps2
    * provides a detailed description of
    * the theory and usage of this model layout as well as a set of
    * functions to manipulate models for use by bundle developers.
    *
    * @field wi The work-item-id
    * @field value The value of the cell
    * @field indexes The identifier for the cell -- a set of unsigned integers
    *                e.g., [1,2,1,3]
    */
  EXPORT Layout_Model2 := RECORD
    t_work_item wi;
    t_fieldReal value;
    t_indexes indexes;
  END;

  // Note: Layout_Model has been deprecated in favor of Layout_Model2, which
  // should be used as the basis of the model for new Bundles or Bundles
  // undergoing major revision.
  // Generic Layout describing the model 'learned' by a Machine Learning algorithm.
  EXPORT Layout_Model := RECORD
    t_Work_Item wi;       // Work-item of the model
    t_RecordID  id;       // Identifies the component type within the model
    t_FieldNumber number; // meaning varies by ID
    t_FieldReal value;    // The model parameter value
  END;

  // Generic Layout describing the model 'learned' by a Machine Learning algorithm.
  // See NamingTree.ecl for details on using this format.
  //EXPORT Layout_Model2 := NamingTree.ntNumeric;

  // Classification definitions
  EXPORT Classify_Result := RECORD(DiscreteField)
    REAL8 conf;  // Confidence - high is good
  END;
  EXPORT l_result := Classify_Result : DEPRECATED('Use Classify_Result');

  // Result structures for the common analytic methods (see Analysis.ecl)
  /**
    * Class_Stats
    *
    * Layout for data returned from Analysis.Regression.ClassStats
    *
    * @field wi Work-item identifier
    * @field classifier The field number associated with this dependent variable, for
    *                   multi-variate classification.  Otherwise 1.
    * @field class The class label associated with this record
    * @field classCount The number of times the class was seen in the data
    * @field classPct The percent of records with this class.
    */
  EXPORT Class_Stats := RECORD
    t_Work_Item wi;
    t_FieldNumber classifier; // Dependent column identifier for multi-variate
    t_Discrete class;
    t_Discrete classCount;
    t_FieldReal classPct;
  END;
  /**
    * Confusion_Detail
    *
    * Layout for storage of the confusion matrix for ML Classifiers
    * Each row represents a pairing of a predicted class and an actual class
    *
    * @field wi Work item identifier
    * @field classifier The field number associated with this dependent variable, for
    *                   multi-variate.  Otherwise 1.
    * @field actual_class The target class number -- the expected result.
    * @field predict_class The class number predicted by the ML algorithm
    * @field occurs The number of times this pairing of (actual / predicted) classes occurred
    * @field correct Boolean indicating if this represents a correct prediction (i.e.
    *                predicted = actual)
    * @field pctActual The percent of items that were actually of <actual_class> that
    *                  were predicted as <predict_class>.
    * @field pctPred Indicates the percent of items that were predicted as <predict_class>
    *                that were actually of <actual_class>.
    */
  EXPORT Confusion_Detail := RECORD
    t_work_item wi;
    t_FieldNumber classifier;   // Dependent column identifier
    t_Discrete actual_class;
    t_Discrete predict_class;
    UNSIGNED4 occurs;
    BOOLEAN correct;
    t_FieldReal pctActual := 0;
    t_FieldReal pctPred := 0;
  END;
  /** Classification_Accuracy
    *
    * Results layout for Analysis.Classification/Accuracy
    * @field wi Work item identifier
    * @field classifier The field number associated with this dependent variable, for
    *                   multi-variate.  Otherwise 1.
    * @field errCnt The number of errors (i.e. predicted <> actual)
    * @field recCnt The total number or records in the test set
    * @field Raw_Accuracy The percentage of samples properly classified (0.0 - 1.0)
    * @field PoD Power of Discrimination.  Indicates how this classification performed
    *           relative to a random guess of class.  Zero or negative indicates that
    *           the classification was no better than a random guess.  1.0 indicates a
    *           perfect classification.  For example if there are two equi-probable classes,
    *           then a random guess would be right about 50% of the time.  If this
    *           classification had a Raw Accuracy of 75%, then its PoD would be .5
    *           (half way between a random guess and perfection).
    * @field PoDE Power of Discrimination Extended.  Indicates how this classification
    *           performed relative to guessing the most frequent class (i.e. the trivial
    *           solution).  Zero or negative indicates that this classification is no
    *           better than the trivial solution.  1.0 indicates perfect classification.
    *           For example, if 95% of the samples were of class 1, then the trivial
    *           solution would be right 95% of the time.  If this classification had a
    *           raw accuracy of 97.5%, its PoDE would be .5 (i.e. half way between
    *           trivial solution and perfection).
    * @field Hamming_Loss Hamming loss. The percentage of records misclassified.
    *           Useful for multilabel classification. It is equal to 1 - Raw_Accuracy.
    *
    */
  EXPORT Classification_Accuracy := RECORD
    t_Work_Item wi;
    t_FieldNumber classifier;
    UNSIGNED recCnt;
    UNSIGNED errCnt;
    REAL Raw_Accuracy;
    REAL PoD;
    REAL PoDE;
    REAL Hamming_Loss;
  END;
  /**
    * Class_Accuracy
    *
    * Results layout for Analysis.Classification.AccuracyByClass
    * See https://en.wikipedia.org/wiki/Precision_and_recall for a more detailed
    * explanation.
    *
    * @field wi Work item identifier
    * @field classifier The field number associated with this dependent variable, for
    *                   multi-variate.  Otherwise 1.
    * @field class The class to which the analytics apply
    * @field precision The precision of the classification for this class
    *                  (i.e. True Positives / (True Positives + FalsePositives)).
    *                  What percentage of the items that we predicted as being
    *                  in this class are actually of this class?
    * @field recall The completeness of recall for this class
    *                  (i.e. True Positives / (True Positives + False Negatives))
    *                  What percentage of the items that are actually in this class
    *                  did we correctly predict as this class?
    * @field FPR The false positive rate for this class
    *                  (i.e. False Positives / (False Positives + True Negatives))
    *                  What percentage of the items not in this class did we falsely
    *                  predict as this class?
    * @field f_score The balanced F-score for this class
    *                  (i.e. 2 * (precision * recall) / (precision + recall))
    *                  The harmonic mean of precision and recall. Higher values are better.
    *
    */
  EXPORT Class_Accuracy := RECORD
    t_Work_Item wi;
    t_FieldNumber classifier;
    t_Discrete class;
    REAL precision;
    REAL recall;
    REAL FPR;
    REAL f_score;
  END;
  /**
    * AUC_Result
    *
    * Result layout for Analysis.Classification.AUC.
    *
    * Provides the area under the Receiver Operating Characteristic curve for the given
    * given data. This area is a measure of the classifier's ability to distinguish between
    * classes.
    *
    * @field wi Work item identifier
    * @field classifier The field number associated with this dependent variable, for
    *                   multi-variate.  Otherwise 1.
    * @field class The class to which the analytics apply.
    * @field AUC The value of the Area Under the Receiver Operating Characteristic curve
    *            for this class. This value ranges between 0 and 1. A higher value is an
    *            indication of a better classifier.
    */
  EXPORT AUC_Result := RECORD
    t_Work_Item wi;
    t_FieldNumber classifier;
    t_Discrete class;
    t_FieldReal AUC;
  END;
  /**
    * Regression_Accuracy
    *
    * Results layout for Analysis.Regression.Accuracy
    *
    * @field wi Work item identifier
    * @field regressor The field number associated with this dependent variable, for
    *                   multi-variate.  Otherwise 1.
    * @field R2 The R-Squared value (Coefficient of Determination) for the regression.
    *           R-squared of zero or negative indicates that the regression has no predictive
    *           value.  R2 of 1 would indicate a perfect regression.
    * @field MSE Mean Squared Error = SUM((predicted - actual)^2) / N (number of datapoints)
    * @field RMSE Root Mean Squared Error = MSE^.5 (Square root of MSE)
    *
    */
  EXPORT Regression_Accuracy := RECORD
    t_Work_Item wi;
    t_FieldNumber regressor;
    t_FieldReal R2;
    t_FieldReal MSE;
    t_FieldReal RMSE;
  END;
  /**
    * Contingency_Table
    *
    * Contains the contingency table for every combination of feature and classifier.
    * Result layout for Analysis.FeatureSelection.Contingency
    * 
    * @field wi Work item identifier
    * @field fnumber The feature number
    * @field snumber The sample number or the classifier number
    * @field fclass The feature label / class
    * @field sclass The sample (classifier) label / class
    * @field cnt The number of samples with feature label fclass and classifier label sclass
    *            Does not contain entries for combinations with no members.
    *
    */
  EXPORT Contingency_Table := RECORD
    t_Work_Item wi;
    t_FieldNumber fnumber;
    t_FieldNumber snumber;
    t_Discrete fclass;
    t_Discrete sclass;
    INTEGER cnt := COUNT(GROUP);
  END;
  /**
    * Chi2_Result
    *
    * Result layout for Analysis.FeatureSelection.Chi2
    * Contains chi2 value for every combination of feature and classifier per work item,
    * and its corresponding p value.
    *
    * @field wi Work item identifier
    * @field fnumber Feature number
    * @field snumber Sample number / number of classifier
    * @field dof The number of degrees of freedom
    * @field x2 The chi2 value for this combination. Higher values indicate more closely
                  related variables
    * @field p The p-value, which is the area under the chi-square probability density function
    *          curve to the right of the specified x2 value. The probability that the variables
    *          are not closely related
    *
    */
  EXPORT Chi2_Result := RECORD
    t_Work_Item wi;
    t_FieldNumber fnumber;
    t_FieldNumber snumber;
    INTEGER dof;
    t_FieldReal x2;
    t_FieldReal p;
  END;
  /**
    * ARI_Result
    *
    * Result layout for Analysis.Clustering.ARI
    *
    * Contains the Adjusted Rand Index for each work item.
    *
    * @field wi Work item identifier
    * @field value The ARI for the model
    *
    */
  EXPORT ARI_Result := RECORD
    t_Work_Item wi;
    t_FieldReal value;
  END;
  /**
    * SampleSilhouette_Result
    *
    * Result layout for Analysis.Clustering.SampleSilhouetteScore
    * 
    * Contains the silhouette score for each sample datapoint.
    *
    * @field wi Work item identifier
    * @field id Sample datapoint identifier
    * @field value Silhouette score
    *
    */
  EXPORT SampleSilhouette_Result := RECORD
    t_Work_Item wi;
    t_RecordID id;
    t_FieldReal value;
  END;
  /**
    * Silhouette_Result
    *
    * Result layout for Analysis.Clustering.SilhouetteScore
    * 
    * Contains the silhouette score for each work item.
    *
    * @field wi Work item identifier
    * @field score Silhouette score
    *
    */
  EXPORT Silhouette_Result := RECORD
    t_Work_Item wi;
    t_FieldReal score;
  END;
  // End Analytic result structures
  
  // Clustering structures required by cluster analysis methods (See Analysis.ecl)
  /**
    * ClusterLabels format defines the distance space where
    * each cluster defined by a center and its closest samples.
    * It is the same as KMeans.Types.KMeans_Model.Labels.
    *
    * @field  wi      The model identifier.
    * @field  id      The sample identifier.
    * @field  label   The identifier of the closest center to the sample.
    */
  EXPORT ClusterLabels := RECORD
    t_Work_Item wi;      // Model Identifier
    t_RecordID  id;      // Sample Identifier
    t_RecordID  label;   // Center Identifier
  END;
  // End Clustering structures
  
  // Data diagnostic definition
  EXPORT Data_Diagnostic := RECORD
    t_work_item wi;
    BOOLEAN valid;                 // Flag indicating failure of ANY diagnostic tests for wi
    SET OF VARSTRING message_text; // List of failed diagnostic tests for a wi
  END;

  /**
    * Field_Mapping is the format produced by ToField for field-name mapping.
    * 
    * @field orig_name The name of the field in the original layout
    * @field assigned_name The integer field number used in the ML algorithm stored as a STRING
    *
    */
  EXPORT Field_Mapping := RECORD
    STRING orig_name;      // The name of the field in the original layout
    STRING assigned_name;  // The integer field number used in the ML algorithm
  END;
  /**
    * LUCI Record -- A dataset of lines each containing a string
    * This is the DATASET format in which ML algorithm export LUCI files.
    *
    * @field line A single line in the LUCI csv file
    *
    */
  EXPORT LUCI_Rec := RECORD
    STRING line;
  END;
  /**
    * Classification_Scores
    *
    * The probability or confidence, per class, that a sample belongs to that class.
    *
    * @field wi The work-item identifier.
    * @field id The record-id of the sample.
    * @field classifier The field number associated with this dependent variable, for
    *                   multi-variate. Otherwise 1.
    * @field class The class label.
    * @field prob The percentage of trees that assigned this class label,
    *             which is a rough stand-in for the probability that the label
    *             is correct.
    */
  EXPORT Classification_Scores := RECORD
    t_Work_Item wi;
    t_RecordID id;
    t_FieldNumber classifier;
    t_Discrete class;
    t_FieldReal prob;
  END;
END;
