/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT STD;
IMPORT $.Files;

STD.File.SprayDelimited('192.168.56.101',
       '/var/lib/HPCCSystems/mydropzone/housing.csv',
       ,,,, 
       'mythor',
       Files.rawDataPath,
       -1,
       'http://192.168.56.101:8010/FileSpray',,TRUE);
