/**
 * Given a file which is sorted by the work item identifier and
 * INFIELD (and possibly other values), add sequence numbers within
 * the range of each infield.
 * Slighly elaborate code is to avoid having to partition the data
 * to one value of infield per node and to work with very large
 * numbers of records where a global count project would be
 * inappropriate.
 * This is useful for assigning rank positions with the groupings.
 *@param infile the input file, any type
 *@param infield field name of grouping field
 *@param seq name of the field to receive the sequence number
 *@param wi_name work item field name, default is wi
 *@return a file of the same type with sequence numbers applied
 */
EXPORT SequenceInField(infile,infield,seq,wi_name='wi') := FUNCTIONMACRO
  LOCAL extend_rec := RECORD(RECORDOF(infile))
    UNSIGNED2 __node;
  END;
  LOCAL extend_rec add_rank(infile le, UNSIGNED c) := TRANSFORM
    SELF.__node := ThorLib.node();
    SELF.seq := c;
    SELF := le;
  END;
  LOCAL grp_in := GROUP(infile, wi_name, infield, LOCAL);
  LOCAL local_seq := PROJECT(grp_in, add_rank(LEFT,COUNTER), LOCAL);
  LOCAL last_by_node := UNGROUP(DEDUP(local_seq, TRUE, RIGHT));
  LOCAL Patch_Tab := RECORD
    UNSIGNED2 __node;
    infile.seq;
    infile.infield;
    infile.wi_name;
    UNSIGNED8 adj := 0;
  END;
  LOCAL patch_raw := PROJECT(last_by_node, Patch_Tab);
  LOCAL patch_grp := GROUP(patch_raw, wi_name, infield, ALL);
  LOCAL patch_seq := SORT(patch_grp, __node);
  LOCAL Patch_Tab calc_adj(Patch_Tab prev, Patch_Tab curr):=TRANSFORM
    SELF.adj := prev.seq + prev.adj;
    SELF := curr;
  END;
  LOCAL patches := UNGROUP(ITERATE(patch_seq, calc_adj(LEFT, RIGHT)));
  LOCAL extend_rec apply_patch(extend_rec rec, Patch_Tab p):=TRANSFORM
    SELF.seq := rec.seq + p.adj;
    SELF := rec;
  END;
  LOCAL patched := JOIN(UNGROUP(local_seq), patches,
                        LEFT.__node=RIGHT.__node
                        AND LEFT.infield=RIGHT.infield
                        AND LEFT.wi_name=RIGHT.wi_name,
                        apply_patch(LEFT, RIGHT), LOOKUP);
  RETURN PROJECT(patched, RECORDOF(infile));
ENDMACRO;
