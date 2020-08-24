/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems.  All rights reserved.
############################################################################## */

/**
 * Assess if two reals are equal
 * tolerance = 0.00001
 */
EXPORT CompareReals(REAL value1, REAL value2) := FUNCTION
  comparisonResult := IF(ABS(value1 - value2) <= 0.00001, TRUE, FALSE);
  RETURN comparisonResult;
END;
