/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;
IMPORT $.^.^.^ as ML_Core;

ML_Core.ToField(Files.labelEncodedData, MLData);
OUTPUT(MLData,, Files.MLDataPath, THOR, COMPRESSED, OVERWRITE);

