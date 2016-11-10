IMPORT $.^ AS ML_Core;
IMPORT $.^.Types AS Types;
//
Work1 := RECORD
  UNSIGNED2 num_2;
  UNSIGNED2 wi_f;
  UNSIGNED4 num_1;
  UNSIGNED2 id_f;
  REAL4 float_1;
  REAL4 float_2;
  STRING str_1;
END;
Work1 gen_work1(UNSIGNED c, UNSIGNED wi) := TRANSFORM
  SELF.id_f := c + 10*(wi-1);
  SELf.num_1 := c + 100;
  SELF.num_2 := c * wi;
  SELF.str_1 := (STRING) c;
  SELF.float_1 := c/3;
  SELF.float_2 := c/7;
  SELF.wi_f := wi;
END;
ds := DATASET(5, gen_work1(COUNTER, 1))
    + DATASET(6, gen_work1(COUNTER+51, 2));
test_data := OUTPUT(ds, NAMED('Test_Input'));

// defaults
ML_Core.ToField(ds, nf_ds1);
ML_Core.FromField(nf_ds1, Work1, ds1_wo_map);
ML_Core.FromField(nf_ds1, Work1, ds1_w_map, nf_ds1_map);
t1a := OUTPUT(nf_ds1, NAMED('Defaults_inv'));
t1b := OUTPUT(nf_ds1_map, NAMED('Defaults_map'));
t1c := OUTPUT(ds1_wo_map, NAMED('Defaults_wo_map_flat'));
t1d := OUTPUT(ds1_w_map, NAMED('Defaults_w_map_flat'));

// Named ID, Default WI
ML_Core.ToField(ds, nf_ds2, id_f);
ML_Core.FromField(nf_ds2, Work1, ds2, nf_ds2_map);
t2a := OUTPUT(nf_ds2, NAMED('id_def_wi_inv'));
t2b := OUTPUT(nf_ds2_map, NAMED('id_def_wi_map'));
t2c := OUTPUT(ds2, NAMED('id_def_wi_flat'));

// Named ID, def WI, list
ML_Core.ToField(ds, nf_ds3,id_f,,, 'float_1, num_1');
ML_Core.FromField(nf_ds3, Work1, ds3, nf_ds3_map);
t3a := OUTPUT(nf_ds3, NAMED('Field_list_inv'));
t3b := OUTPUT(nf_ds3_map, NAMED('Field_list_map'));
t3c := OUTPUT(ds3, NAMED('Field_list_flat'));

// Named ID, WI=2
ML_Core.ToField(ds, nf_ds4,id_f,, 2);
ML_Core.FromField(nf_ds4, Work1, ds4, nf_ds4_map);
t4a := OUTPUT(nf_ds4, NAMED('wi_2_inv'));
t4b := OUTPUT(nf_ds4_map, NAMED('wi_2_map'));
t4c := OUTPUT(ds4, NAMED('wi_2_flat'));

// Named id, Named WI, list
ML_Core.ToField(ds, nf_ds5, id_f, wi_f,, 'float_1,num_1');
ML_Core.FromField(nf_ds5, Work1, ds5, nf_ds5_map);
t5a := OUTPUT(nf_ds5, NAMED('With_wi_list_inv'));
t5b := OUTPUT(nf_ds5_map, NAMED('With_wi_list_map'));
t5c := OUTPUT(ds5, NAMED('With_wi_list_flat'));

// Named ID, Named WI
ML_Core.ToField(ds, nf_ds6, id_f, wi_f);
ML_Core.FromField(nf_ds6, Work1, ds6_w_map, nf_ds6_map);
ML_Core.FromField(nf_ds6, Work1, ds6_wo_map);
t6a := OUTPUT(nf_ds6, NAMED('With_wi_inv'));
t6b := OUTPUT(nf_ds6_map, NAMED('With_wi_map'));
t6c := OUTPUT(ds6_w_map, NAMED('With_wi_w_map_flat'));
t6d := OUTPUT(ds6_wo_map, NAMED('With_wi_wo_map_flat'));

EXPORT to_from := PARALLEL(
   test_data
  ,t1a
  ,t1b
  ,t1c
  ,t1d
  ,t2a
  ,t2b
  ,t2c
  ,t3a
  ,t3b
  ,t3c
  ,t4a
  ,t4b
  ,t4c
  ,t5a
  ,t5b
  ,t5c
  ,t6a
  ,t6b
  ,t6c
  ,t6d
);