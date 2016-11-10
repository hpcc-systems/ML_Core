IMPORT $.^ AS ML_Core;

ds := DATASET([{1,1,1,10}], ML_Core.Types.NumericField);
gen0 := ML_Core.Generate.ToPoly(ds);

EXPORT generate := OUTPUT(gen0, NAMED('Values_of_10'));