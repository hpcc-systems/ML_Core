/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.  All rights reserved.
############################################################################## */

EXPORT Files := MODULE
  EXPORT pathPrefix := '~Preprocessing::PerformanceTest::LabelEncoder::';  

  EXPORT RawDataLayout := RECORD
    UNSIGNED id;
    STRING bin_0;
    STRING bin_1;
    STRING bin_2;
    STRING bin_3;
    STRING bin_4;
    STRING nom_0;
    STRING nom_1;
    STRING nom_2;
    STRING nom_3;
    STRING nom_4;
    STRING nom_5;
    STRING nom_6;
    STRING nom_7;
    STRING nom_8;
    STRING nom_9;
    STRING ord_1;
    STRING ord_2;
    STRING ord_3;
    STRING ord_4;
    STRING ord_5;
    STRING day;
    STRING month;
    STRING target;
  END;
  EXPORT rawDataPath := pathPrefix + 'rawData';
  EXPORT rawData := DATASET(rawDataPath, RawDataLayout, CSV(HEADING(1)));

  EXPORT EncodedDataLayout := RECORD
    UNSIGNED id;
    STRING bin_0;
    STRING bin_1;
    STRING bin_2;
    STRING bin_3;
    STRING bin_4;
    INTEGER nom_0;
    INTEGER nom_1;
    INTEGER nom_2;
    INTEGER nom_3;
    INTEGER nom_4;
    INTEGER nom_5;
    INTEGER nom_6;
    INTEGER nom_7;
    INTEGER nom_8;
    INTEGER nom_9;
    INTEGER ord_1;
    INTEGER ord_2;
    INTEGER ord_3;
    INTEGER ord_4;
    INTEGER ord_5;
    STRING day;
    STRING month;
    STRING target;
  END;
END;