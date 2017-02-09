IMPORT $ AS ML_Core;
IMPORT ML_Core.Types;

/*
  This module exists to turn one column into new columns
*/
EXPORT Generate := MODULE

  EXPORT tp_Method := ENUM(UNSIGNED1, X0=0, LogX, X, XLogX, XX, XXLogX, XXX, XXXLog);
  EXPORT MethodName(tp_Method x) := CHOOSE(x, 'LogX','X','XLogX','XX','XXLogX','XXX',
                                          'XXXLogX','X0');
  /*
    This Attribute generates maxN columns by applying the tp_Methods to the seed column
  */
  Types.NumericField mn(Types.NumericField le,UNSIGNED c) := TRANSFORM
        SELF.number := c;
        SELF.value := IF ( c & 1 = 1, LOG(le.value), 1 ) * POWER(le.value,(c-1));
        SELF := le;
  END;
  EXPORT ToPoly(DATASET(Types.NumericField) seedCol, UNSIGNED maxN=6) :=
                NORMALIZE(seedCol,MIN(maxN,6),mn(LEFT,COUNTER));
End;