/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2018 HPCC Systems®.  All rights reserved.
############################################################################## */
IMPORT ML_Core;
IMPORT ML_Core.Types as Types;
/**
  * This module is a container for any cross-validation methods
  */
EXPORT CrossValidation := MODULE
  /**
    * <p>N-Fold Cross Validation is a way to validate the effectiveness
    * of a regression or classification without having to segregate
    * test data from training data.
    * <p>The results of the N-Fold Cross Validation approximate the expected result
    * of training on all of the data samples and testing those results on other
    * data from the same distribution.
    * <p>This allows a model that is built on all available labeled data to be
    * effectively assessed. Note that this process does not produce the target
    * model, but only estimates the 'out-of-sample' error statistics that such
    * a model would produce.
    * <p>The method is as follows:<ul>
    * <li>Randomly split independent and dependent data into N (e.g. 10) 'folds'.</li>
    * <li>Train N separate models, using N-1 of the folds as training data (e.g. 9).</li>
    * <li>Test each model using the 1 fold that was not in the training set.</li>
    * <li>Aggregate the test results across the N tests.</li></ul>
    *
    * <p>Any of the HPCC Machine Learning methods may be used with N-Fold Cross Validation
    * The ML module to be used is passed as a parameter.
    * <p>N-Fold Cross Validation can be used for regression or classification.  If the
    * dependent data is in NumericField format, it is treated as a regression and
    * regression analytics are returned.  If it is in DiscreteField format, then
    * it is treated as a Classification, and Classification analytics are return.
    * <p>Using the wrong dependent data type for the given learner will result in un-
    * handled errors.
    * <p>The returned MODULE exports the following attributes:
    * <p>For Classification:<ul>
    * <li>ClassStats - Assesses Classes Contained in the Training Data (see Types.Class_Stats).</li>
    * <li>Accuracy Overall Accuracy of the classification (see Types.Classification_Accuracy).</li>
    * <li>AccuracyByClass Precision and Recall for each class (see Types.Class_Accuracy).</li>
    * <li>ConfusionMatrix Frequency of predicted / actual class pairings (see Types.Consusion_Detail).</li></ul>
    * <p>For Regression:<ul>
    * <li>Accuracy (see Types.Regression_Accuracy).</li></ul>
    *
    * @param LearnerName The attribute that holds the instantiated ML module.
    * @param IndepDS The independent data to be used for training and testing.
    * @param DepDS The dependent data to be used for training and testing.
    * @param NumFolds The number of folds to use.  Ten is typically considered adequate.
    * @return Result MODULE with attributes for assessing the strength of the model.
    * 
    */
  EXPORT NFoldCV(LearnerName, IndepDS, DepDS, NumFolds) := FUNCTIONMACRO
    SHARED learner:= LearnerName;
    LOADXML('<xml/>');
    #DECLARE(predictStr)
    #DECLARE(analyzeStr)
    #DECLARE(fields);
    #EXPORTXML(fields, RECORDOF(DepDS));
    #FOR(fields)
      #FOR(Field)
        #IF(%'{@label}'% = 'value')
          #IF(%'{@type}'% = 'integer')
            // DiscreteField -- Treat as Classification
            #SET(predictStr, 'SHARED Predicted0 := learner.Classify(Mod, t_indep);\n')
            #SET(analyzeStr, 'EXPORT ClassStats :=  ML_Core.Analysis.Classification.ClassStats(Actual);\n' +
                          'EXPORT Accuracy := ML_Core.Analysis.Classification.Accuracy(Predicted, Actual);\n' +
                          'EXPORT AccuracyByClass := ML_Core.Analysis.Classification.AccuracyByClass(Predicted, Actual);\n' +
                          'EXPORT ConfusionMatrix := ML_Core.Analysis.Classification.ConfusionMatrix(Predicted, Actual);\n')
          #ELSE
            // NumericField -- Treat as Regression
            #SET(predictStr, 'SHARED Predicted0 := learner.Predict(Mod, t_indep);\n')
            #SET(analyzeStr, 'EXPORT Accuracy := ML_Core.Analysis.Regression.Accuracy(Predicted, Actual);\n')
          #END
        #END
      #END
    #END

    idFoldRec := RECORD
      Types.t_Work_Item wi;
      Types.t_FieldNumber number; // For multi-variate
      Types.t_FieldNumber fold;
      Types.t_RecordID id;
    END;
    dsRecordRnd := RECORD(RECORDOF(DepDS))
      Types.t_FieldNumber rnd := 0;
    END; 
    dsRecordRnd AddRandom(RECORDOF(DepDS) l) :=TRANSFORM
      SELF.rnd := RANDOM();
      SELF := l;
    END;
    FoldNDS(DATASET(RECORDOF(IndepDS)) indData, DATASET(RECORDOF(DepDS)) depData, DATASET(idFoldRec) ds_folds,
              Types.t_Discrete num_fold) := MODULE
      EXPORT trainIndep := JOIN(indData, ds_folds(fold <> num_fold), LEFT.wi = RIGHT.wi AND LEFT.id = RIGHT.id,
                        TRANSFORM(RECORDOF(IndepDS), SELF.id:= LEFT.id,
                          SELF.wi:= num_fold + (LEFT.wi - 1) * NumFolds, SELF := LEFT), LOCAL);
      EXPORT trainDep   := JOIN(depData, ds_folds(fold <> num_fold), LEFT.wi = RIGHT.wi AND LEFT.id = RIGHT.id
                          AND LEFT.number = RIGHT.number,
                        TRANSFORM(RECORDOF(DepDS), SELF.id:= LEFT.id,
                          SELF.wi:= num_fold + (LEFT.wi - 1) * NumFolds, SELF := LEFT), LOCAL);
      EXPORT testIndep  := JOIN(indData, ds_folds(fold = num_fold), LEFT.wi = RIGHT.wi AND LEFT.id = RIGHT.id,
                        TRANSFORM(RECORDOF(IndepDS), SELF.id:= LEFT.id,
                          SELF.wi:= num_fold + (LEFT.wi - 1) * NumFolds, SELF := LEFT), LOCAL);
      EXPORT testDep    := JOIN(depData, ds_folds(fold = num_fold), LEFT.wi = RIGHT.wi AND LEFT.id = RIGHT.id
                          AND LEFT.number = RIGHT.number,
                        TRANSFORM(RECORDOF(DepDS), SELF.id:= LEFT.id,
                          SELF.wi:= num_fold + (LEFT.wi - 1) * NumFolds, SELF := LEFT), LOCAL);
    END;
    dRnd := PROJECT(DepDS, AddRandom(LEFT), LOCAL);
    dRndSorted := SORT(dRnd, wi, number, rnd);
    ds_parts := DISTRIBUTE(PROJECT(dRndSorted, TRANSFORM(idFoldRec, SELF.fold := (COUNTER - 1) % NumFolds + 1, SELF:= LEFT)),
                  HASH32(wi, id));
    dIndep  := DISTRIBUTE(IndepDS, HASH32(wi, id));
    dDep    := DISTRIBUTE(DepDS, HASH32(wi, id));
    #DECLARE (FoldString)    #SET (FoldString, '');
    #DECLARE (Ndx)
    #SET (Ndx, 1);
    #LOOP
      #IF (%Ndx% > NumFolds)  
         #BREAK         // break out of the loop
      #ELSE             //otherwise
        #APPEND(FoldString,'__fold'      + %'Ndx'% + '__ := FoldNDS(dIndep, dDep, ds_parts, ' + %'Ndx'% + '); \n');
        #APPEND(FoldString,'__indepN'    + %'Ndx'% + '__ := __fold' + %'Ndx'% + '__.trainIndep; \n');
        #APPEND(FoldString,'__depN'      + %'Ndx'% + '__ := __fold' + %'Ndx'% + '__.trainDep; \n');
        #APPEND(FoldString,'__t_indepN'  + %'Ndx'% + '__ := __fold' + %'Ndx'% + '__.testIndep; \n');
        #APPEND(FoldString,'__t_depN'    + %'Ndx'% + '__ := __fold' + %'Ndx'% + '__.testDep; \n');
        #SET (Ndx, %Ndx% + 1)  //and increment the value of Ndx
      #END
    #END
    #EXPAND(%'FoldString'%);

    #SET (Ndx, 1);
    #DECLARE (indep) #SET (indep, '__indep__ := ');
    #DECLARE (dep) #SET (dep, '__dep__ := ');
    #DECLARE (t_indep) #SET (t_indep, '__t_indep__ := ');
    #DECLARE (t_dep) #SET (t_dep, '__t_dep__ := ');
    #LOOP
      #IF (%Ndx% < NumFolds)
        #APPEND(indep,   '__indepN'   + %'Ndx'% + '__ + ');
        #APPEND(dep,     '__depN'     + %'Ndx'% + '__ + ');
        #APPEND(t_indep, '__t_indepN' + %'Ndx'% + '__ + ');
        #APPEND(t_dep,   '__t_depN'   + %'Ndx'% + '__ + ');
        #SET (Ndx, %Ndx% + 1)  //and increment the value of Ndx
      #ELSE
        #APPEND(indep,   '__indepN'   + %'Ndx'% + '__;\n');
        #APPEND(dep,     '__depN'     + %'Ndx'% + '__;\n');
        #APPEND(t_indep, '__t_indepN' + %'Ndx'% + '__;\n');
        #APPEND(t_dep,   '__t_depN'   + %'Ndx'% + '__;\n');
        #BREAK
      #END
    #END
    #EXPAND(%'indep'%); // All Training Independents
    #EXPAND(%'dep'%); // All Training Dependents
    #EXPAND(%'t_indep'%); // All Testing Independents
    #EXPAND(%'t_dep'%);  // All Testing Dependents

    CVResults(DATASET(RECORDOF(IndepDS)) indep, DATASET(RECORDOF(DepDS)) dep,
              DATASET(RECORDOF(IndepDS)) t_indep, DATASET(RECORDOF(DepDS)) t_dep) := MODULE
      // At this point, each fold has been expanded out and converted to a unique work-item id.
      // This gives us one wi per fold, per original wi.  The conversion is
      // new_wi = foldNum + (orig_wi-1) * NumFolds)
      SHARED Mod := learner.GetModel(indep, dep);
      #EXPAND(%'predictStr'%)
      // Now that we've built <number_of_work_items> * <NumFolds> models, and used those models
      // to predict <orig_num_records> test points (that were not used in the training sets),
      // We can (safely) combine all the test points back together for analysis.
      // We do this by reversing the mapping of work items.
      // The conversion is orig_wi = (new_wi -1) DIV NumFolds + 1.
      // This is safe because each fold was only used once for test points, and because we've already done the
      // ML prediction using the distinct models for each fold.
      SHARED Predicted := PROJECT(Predicted0, TRANSFORM(RECORDOF(Predicted0),
                            SELF.wi := (LEFT.wi - 1) DIV NumFolds + 1, SELF := LEFT));
      SHARED Actual := PROJECT(t_dep, TRANSFORM(RECORDOF(t_dep),
                            SELF.wi := (LEFT.wi - 1) DIV NumFolds + 1, SELF := LEFT));
      #EXPAND(%'analyzeStr'%)
      EXPORT Model := Mod;
    END;
    rslt := CVResults(__indep__, __dep__, __t_indep__, __t_dep__);
    RETURN rslt;
  ENDMACRO;
END;