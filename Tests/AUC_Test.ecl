IMPORT $.^ AS ML_Core;
IMPORT ML_Core.Analysis AS Analysis;
IMPORT ML_Core.Types AS Types;
IMPORT Python;

// Generate Test data

num_wis := 2;
num_samples := 200;
num_variables := 3;
num_classes := 4;

Types.DiscreteField RandomSample(INTEGER x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples * num_variables) + 1;
  SELF.id := (x-1) DIV (num_variables) + 1;
  SELF.number := (x-1) % num_variables + 1;
  SELF.value := (RANDOM()) % (4);
END;

Types.Classification_Scores RandomScore(INTEGER x) := TRANSFORM
  SELF.wi := (x-1) DIV (num_samples * num_variables * num_classes) + 1;
  SELF.id := (x-1) DIV (num_variables * num_classes) + 1;
  SELF.classifier := ((x-1) DIV (num_classes)) % num_variables + 1;
  SELF.class := (x-1) % num_classes;
  SELF.prob := (RANDOM()%100)/100;
END;

pred := DATASET(num_wis * num_samples * num_variables * num_classes, RandomScore(COUNTER));
actual := DATASET(num_wis * num_samples * num_variables, RandomSample(COUNTER));

// Test the AUC score with random scores for predictions. Should produce values close to 0.5.

ML_Core_AUC := ML_Core.Analysis.Classification.AUC(pred, actual);

EXPORT AUC_Test := OUTPUT(ML_Core_AUC);
