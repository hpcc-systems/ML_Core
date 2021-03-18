/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

IMPORT STD;
IMPORT $.Files;

sourceIP := '192.168.56.101'; //<your cluster's ip address>
sourcePath := '/var/lib/HPCCSystems/mydropzone/housing.csv';
espServerIpPort := 'http://' + sourceIP + ':8010/FileSpray'; //esp server address

STD.File.SprayDelimited(sourceIP,
       sourcePath,
       ,,,, 
       'mythor',
       Files.rawDataPath,
       -1,
       espServerIpPort,,TRUE);





