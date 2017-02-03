IMPORT $.^ AS ML_Core;
IMPORT ML_Core.Types;
// Generate test data
Columns := 6;
Types.NumericField make(UNSIGNED c, Types.t_Work_Item wi) := TRANSFORM
  col_num := ((c-1) % Columns) + 1;
  SELF.wi := wi;
  SELF.id := ((c-1) DIV Columns) + 1;
  SELF.number := col_num;
  SELF.value := MAP(col_num = 1   => (REAL8)(((c-1) DIV 10) + 1),
                    col_num = 2   => RANDOM()%20,
                    col_num = 3   => ((RANDOM()-1)%1000)/1000,
                    col_num = 4   =>(RANDOM()%10000)/1000,
                    (RANDOM()%1000000)/1000);
END;
wi_1 := DATASET(10*Columns, make(COUNTER, 1), DISTRIBUTED);
wi_2 := DATASET(13*Columns, make(COUNTER, 2), DISTRIBUTED);

instruct := ML_Core.Discretize.i_ByRounding([4])
          + ML_Core.Discretize.i_ByTiling([3])
          + ML_Core.Discretize.i_ByBucketing([5,6], 6);

discrete_values := ML_Core.Discretize.Do(wi_1+wi_2, instruct);
grouped_values := GROUP(discrete_values, wi, number, ALL);
report_data := UNGROUP(TOPN(grouped_values, 10, wi, id));

Work := RECORD(Types.DiscreteField)
  REAL8 orig_value;
END;
w_orig := JOIN(report_data, wi_1+wi_2,
              LEFT.wi=RIGHT.wi AND LEFT.id=RIGHT.id
              AND LEFT.number=RIGHT.number,
              TRANSFORM(Work, SELF.orig_value:=RIGHT.value, SELF:=LEFT));
report := SORT(w_orig, wi, number, value, id);
EXPORT test_discrete := OUTPUT(report, NAMED('First_10_each_field'));