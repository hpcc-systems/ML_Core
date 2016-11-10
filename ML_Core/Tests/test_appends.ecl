IMPORT $.^ AS ML_Core;
IMPORT Std.system.thorlib;

Work1 := RECORD
  STRING content;
  UNSIGNED4 node;
  UNSIGNED4 pos;
END;
Work1 gen(UNSIGNED c) := TRANSFORM
  SELF.node := ThorLib.node();
  SELF.pos := c;
  SELF.content := 'Data on ' + INTFORMAT(ThorLib.node(), 4, 1)
                + ' record ' + INTFORMAT(c, 8, 1);
END;
test_ds := DATASET(2000, gen(COUNTER), LOCAL);

ML_Core.AppendID(test_ds, rid, test_id);
test_id_list := ASSERT(TABLE(test_id, {used:=COUNT(GROUP)}, rid, MERGE),
                      used=1, 'duplicate ID assigned by Append', FAIL);
test_id_tab := TABLE(test_id_list, {used, c:=COUNT(GROUP)}, used, FEW, UNSORTED);

ML_Core.AppendSeqID(test_ds, rid, test_seq);
test_seq_list := ASSERT(TABLE(test_seq, {used:=COUNT(GROUP)}, rid, MERGE),
                        used=1, 'duplicate ID assigned by AppendSeq', FAIL);
test_seq_tab := TABLE(test_seq_list, {used, c:=COUNT(GROUP)}, used, FEW, UNSORTED);


export test_appends := PARALLEL(OUTPUT(test_id_tab, NAMED('Test_ID'))
  , OUTPUT(test_seq_tab, NAMED('Test_Seq_ID'))
);