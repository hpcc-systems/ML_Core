IMPORT $.^ AS ML_Core;

ds := DATASET([{1,1,1,10}], ML_Core.Types.NumericField);
expectedSet := [1, 10, 10, 100, 100, 1000, 1000];
gen0 := ML_Core.Generate.ToPoly(ds);

gen := PROJECT(gen0, TRANSFORM({gen0, INTEGER expected}, SELF.expected := expectedSet[LEFT.number],
                                      SELF := LEFT));

EXPORT generate := OUTPUT(gen, NAMED('Results'));