IMPORT $ AS ML_Core;
IMPORT ML_Core.Types;

/*
  This module exists to turn one column into new columns
*/
/**
  * Increase dimensionality by adding polynomial transforms of the data to create
  * new feature columns. This can be useful, for example, when building a linear
  * model against data that may not have linear relationships.
  **/
EXPORT Generate := MODULE
  /**
    * Enumeration of polynomial methods.
    * @value LogX = 1
    * @value X = 2
    * @value XLogX = 3
    * @value XX = 4 -- X squared
    * @value XXLogX = 5
    * @value XXX = 6 -- X cubed
    * @value XXXLogX = 7
    **/
  EXPORT tp_Method := ENUM(UNSIGNED1, X0=0, LogX, X, XLogX, XX, XXLogX, XXX, XXXLogX);
  /**
    * Convert a column number into a descriptive label.
    *
    * @param x The column number to describe.
    * @return The descriptive label.
    **/
  EXPORT MethodName(tp_Method x) := CHOOSE(x, 'LogX','X','XLogX','XX','XXLogX','XXX',
                                          'XXXLogX','X0');
  /*
    This Attribute generates maxN columns by applying the tp_Methods to the seed column
  */
  Types.NumericField mn(Types.NumericField le,UNSIGNED c) := TRANSFORM
        SELF.number := c;
        order := c DIV 2; // The order of x to use.
        SELF.value := IF ( c & 1 = 1, LOG(le.value), 1 ) * POWER(le.value,order);
        SELF := le;
  END;
  /**
    * Generate up to seven, successively higher order, features from a
    * single given feature.
    * <p>The generated features are:<ol>
    * <li>LogX (logs are base 10)</li>
    * <li>X</li>
    * <li>XLogX</li>
    * <li>X^2</li>
    * <li>X^2LogX</li>
    * <li>X^3</li>
    * <li>X^3LogX</li></ol>
    * <p> Note that the returned fields will be numbered 1-7, as above. 
    * @param seedCol A single column of NumericField data.  The number field is ignored.
    * @param maxN (Optional) The number of new columns to generate.  For example: If 1,
    *             then one feature, LogX is generated. If 3, then LogX, X, and X^2 features are
    *             generated.  The default is 7, in which case, all features are generated.
    * @return DATASET(NumericField) with numOriginalRecs * maxN records.
    * @see Types.NumericField
    **/
  EXPORT ToPoly(DATASET(Types.NumericField) seedCol, UNSIGNED maxN=7) :=
                NORMALIZE(seedCol,MIN(maxN,7),mn(LEFT,COUNTER));
End;