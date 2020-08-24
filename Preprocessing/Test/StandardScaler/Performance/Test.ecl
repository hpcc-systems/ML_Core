IMPORT ML_CORE;
IMPORT $.^.^.^ as MLPreprocessor;

sampleDataRec := RECORD
    UNSIGNED id;
    REAL feature1;
    REAL feature2;
    REAL feature3;
  END;

sampleData := DATASET([{1, 0, -100.5, -500},
                       {2, 1, -200.5, -250},
                       {3, 2, -300.5,    0},
                       {4, 3, -400.5, 1000}], sampleDataRec);

N := 1000000;
multi_ds := NORMALIZE(sampleData, N, TRANSFORM(sampleDataRec, SELF := LEFT));
ML_Core.AppendSeqId(multi_ds, id, extendSampleData);
ML_CORE.ToField(extendSampleData, extendSampleDataNF);
OUTPUT(extendSampleDataNF);

scaler := MLPreprocessor.StandardScaler(extendSampleDataNF);
scaledData := scaler.scale(extendSampleDataNF);
unscaledData := scaler.unscale(scaledData);

