// Some configuration constants; tweaking these numbers to fit your
// system may help performance
/**
  * Global configuration constants that can be modified if needed.
  **/
EXPORT Config := MODULE
  /**
    * The maximum amount of data to use in a LOOKUP JOIN.
    */
  EXPORT MaxLookup := 1000000000; // At most 1GB of lookup data
  /**
    * The default number of groups to use when discretizing data.
    **/
  EXPORT Discrete := 10; // Default number of groups to discretize things into
  /**
    * The tolerance for rounding error.
    **/
  EXPORT RoundingError := 0.0000000001;
END;
