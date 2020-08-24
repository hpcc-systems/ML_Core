/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT $.Files;
IMPORT $.^.^.^ as MLC;
IMPORT Preprocessing;

MLC.ToField(Files.labelEncodedData, MLData);
OUTPUT(MLData,, Files.MLDataPath, THOR, COMPRESSED, OVERWRITE);

