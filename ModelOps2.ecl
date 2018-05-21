/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2017 HPCC Systems®.  All rights reserved.
############################################################################## */
IMPORT $ AS ML_Core;
IMPORT ML_Core.Types;

NumericField := Types.NumericField;
Layout_Model2 := Types.Layout_Model2;
t_indexes := Types.t_indexes;
t_Work_Item := Types.t_Work_Item;
t_FieldReal := Types.t_FieldReal;

/**
  * This module provides a set of operations to provide manipulation of machine
  * learning models (version 2) in the Types.Layout_Model2 format.
  *
  * <p>Layout_Model2 defines a flexible structure that allows storage of model information for
  * any Machine Learning algorithm.
  *
  * <p>The model is based on a "Naming Tree" paradigm.
  *
  * <p>The naming tree is a data structure that allows a hierarchical name (e.g.
  * object-id) to be attached to each data-cell.  Examples of naming-trees are
  * OID trees such as those used in various network identifiers such as MIBs.
  *
  * <p>This structure is used within ML to store model information.  It is a
  * useful format for several reasons:<ul>
  * <li>It has the flexibility to store complex sets of data in a generic way.</li>
  * <li>It easily stores scalar as well as matrix oriented data.</li>
  * <li>It allows a model to contain data elements within scopes that are
  *   defined at different level.  For example, part of the model may be defined
  *   globally, another may be common for a bundle, while another section is
  *   specific to a given module.</li>
  * <li>It readily allows composite models to be created by encapsulating
  *   entire complex models (or sets of models) within branches of another model.
  *   The individual models can then be extracted from the composite model, and
  *   passed to the modules that created them.</li></ul>
  *
  * <p><b>Theory of Operation</b>
  * 
  * <p>The naming tree (NT) is conceptually simple.  Each cell is identified by a
  * hierarchical numbering scheme of arbitrary depth.  Take, for example, the following
  * NT:
  *<pre>
  * 1
  *   1.1
  *     1.1.1
  *     1.1.2
  *   1.2
  *     1.2.1
  *     1.2.2
  * 2
  *</pre>
  * This tree defines the following leaf (scalar) elements: 1.1.1, 1.1.2, 1.2.1, 1.2.2, 2.
  * <p>Note that the deepest node on any branch is considered a leaf, and branches can be of
  * variable depth.  Note also that there is no explicit creation of branch nodes.  The 
  * branches are implicitly defined by the ids of the leafs.
  * <p>In this example, node 1.1 can be thought as representing an array, thought it could
  * also be thought of as a structure of two distinct scalars, depending on whether the user
  * expects a variable length list under 1.1 (i.e. 1.1.1 - 1.1.N) or a fixed set of cells.
  * <p>Likewise node 1 can be thought of as a matrix (1.r.c, where r is the row index and c
  * is the column index), in cases where r and c are of variable size.
  * 
  * <p>This naming tree also supports the myriad interface, allowing multiple independent
  * work-items to be represented, each of which may duplicate the same structure.
  * 
  * <p>The id is represented by an ECL SET of Unsigned identifiers (e.g. [1,2,1] represents the OID 1.2.1).
  *
  * <p>Each cell is defined by three fields: wi (work-item-id), value (the cell contents) and
  * indexes (the id).
  * <p>A naming tree can be constructed as an inline dataset.  For example, the following
  * creates the tree in the example above:  
    <pre>
  *   DATASET([{1, 3.2, [1,1,1]},
  *            {1, .0297, [1,1,2]},
  *            {1, 2.0, [1,2,1]},
  *            {1, 1550, [1,2,2]},
  *            {1, 8.1, [2]}], Layout_Model2);
  * </pre>
  * <p>There are attributes in this module to assist with manipulation of naming trees:<ul>
  * <li>Creating a NT from a NumericField matrix.</li>
  * <li>Extracting a NumericField matrix from an NT branch.</li>
  * <li>Inserting an NT onto a branch of another NT.</li>
  * <li>Extracting an NT from a branch of an NT.</li></ul>
  *
  * @see Types.Layout_Model2
  */
EXPORT ModelOps2 := MODULE
  SHARED empty_array := DATASET([], Layout_Model2);
  /**
    * Extract an inner sub-tree from an existing model.
    * <p>Work-item = 0 (default) will extract all work-items
    * <p>This is the opposite of Insert.
    *
    * For example:
    * <pre>
    * If I have a tree:
    *  1
    *  2
    *  3
    *   3.1
    *   3.2
    * </pre>
    * and I extract from index 3, it will return the Naming Tree:
    * <pre>
    *  1
    *  2
    * </pre>
    * <p>containing the two sub-cells of the original index 3
    *
    * @param mod The model from which to extract the sub-tree.
    * @param fromIndx The index from which to extract the subtree.
    * @param fromWi The work-item to extract or 0 to extract the same
    *               sub-tree from all work-items.
    * @return A model containing all of the sub-cells below fromIndx
    *         with the indexes adjusted to the top of the tree.
    *
    */
  EXPORT DATASET(Layout_Model2) Extract(DATASET(Layout_Model2) mod,
                                       t_indexes fromIndx, t_work_item fromWi=0) := FUNCTION
    Layout_Model2 extract_indexes(Layout_Model2 a, UNSIGNED prefixSize) := TRANSFORM
      outIndex := a.indexes[prefixSize+1.. ];
      SELF.indexes := outIndex;
      SELF         := a;
    END;
    prefixSize := COUNT(fromIndx);
    filter := mod.indexes[..prefixSize] = fromIndx AND (fromWi = 0 OR mod.wi = fromWi);
    outMod    := PROJECT(mod(filter), extract_indexes(LEFT, prefixSize));
    return outMod;
  END;
  /**
    * Extend the indices of a model to fit within a deeper model.
    *
    * <p>For example, a cell with index [1,2] could be moved to index [1,2,3,1,2]
    * by using atIndex := [1,2,3].
    *
    * @param mod The model whose indexes are to be extended.
    * @param atIndex The prefix indexes to be prepended to the indexes of each cell
    *                in mod.
    * @return A model with extended indexes.
    *
    */
  EXPORT DATASET(Layout_Model2) ExtendIndices(DATASET(Layout_Model2) mod, t_indexes atIndex) := FUNCTION
    Layout_Model2 extend_indexes(Layout_Model2 t) := TRANSFORM
      indxs := atIndex + t.indexes;
      SELF.indexes := indxs;
      SELF         := t;
    END;
    outMod := PROJECT(mod, extend_indexes(LEFT));
    return outMod;
  END;
  /**
    * Insert a model into a sub-tree of an existing model.
    *
    * <p>Extends the indexes of the provided model to fit onto a branch
    * of another model, and concatenates the two models. This is the opposite of
    * extract.
    * For example:
    * <pre>
    * If I have a model:
    * 1
    * 2
    * and a second model:
    * 1
    * 2
    * 3
    * That I would like to insert into the first tree at index 3, I would
    * end up with the tree:
    * 1
    * 2
    * 3
    *  3.1
    *  3.2
    *  3.3
    * </pre>
    * Example code:
    * <pre>
    * mod3 := Insert(mod1, mod2, [3]);
    * </pre>
    * @param mod1 The first (base) model.
    * @param mod2 The sub-model that is to be inserted into mod1.
    * @param atIndx The index prefix (in mod1) that will contain the cells from mod2.
    * @return a new model containing the cells from both models.
    *
    */
  EXPORT DATASET(Layout_Model2) Insert(DATASET(Layout_Model2) mod1, DATASET(Layout_Model2) mod2, t_indexes atIndx) := FUNCTION
    mod2a := ExtendIndices(mod2, atIndx);
    RETURN mod1 + mod2a;
  END;
  /**
    * Convert a two-level model or model sub-tree into a NumericField dataset.
    *
    * <p>The last two indexes of the model subtree are used as the indexes for the NumericField
    * matrix.  The second to last index corresponds to the NF's id field and the
    * last index corresponds to the NF's number field.
    *
    * @param mod The model from which to extract the NumericField matrix.
    * @param fromIndx The index from which to extract the matrix. Example: [3,1,5].
    *                  The default is from the top of the tree i.e. [].
    * @return NumericField matrix in DATASET(NumericField) format.
    *
    */
  EXPORT DATASET(NumericField) ToNumericField(DATASET(Layout_Model2) mod, t_indexes fromIndx = []) := FUNCTION
    NumericField mod_to_nf(Layout_Model2 t) := TRANSFORM
      prefixSize := COUNT(fromIndx);
      suffix := t.indexes[prefixSize+1.. ];
      SELF.id := suffix[1];
      SELF.number := suffix[2];
      SELF := t;
    END;
    prefixSize := COUNT(fromIndx);
    filter := mod.indexes[..prefixSize] = fromIndx;
    outCells := ASSERT(mod(filter), COUNT(indexes) = prefixSize + 2, 'ModelOps2.ToNumericField: Extracted indexes must be exactly 2 dimensional.  Found '
                                       + (COUNT(indexes) - prefixSize), FAIL);
    outMod := PROJECT(outCells, mod_to_nf(LEFT));
    return outMod;
  END;
  /**
    * Convert a NumericField dataset to a 2 level model (or model subtree).
    *
    * <p>A two level model is created and appended to atIndex.
    * <p>The first new index will contain the value of the NumericField's
    * id field, and the second will contain the value of the NumericField's
    * number field.
    * <p>Example: If I have a NumericField with id=1 and number=3, and I use
    * atIndex = [3,1,5], it will create a Naming Tree cell with indexes:
    * [3,1,5,1,3].
    * 
    * @param nf A NumericField dataset to be converted.
    * @param atIndex The index at which to place the new subtree e.g., [3,1,5].
    * @return DATASET(ntNumeric) Naming Tree.
    *
    */
  EXPORT DATASET(Layout_Model2) FromNumericField(DATASET(NumericField) nf, t_indexes atIndex=[]) := FUNCTION
    Layout_Model2 nf_to_mod(NumericField n) := TRANSFORM
      indexes := atIndex + [n.id, n.number];
      SELF.indexes := indexes;
      SELF         := n;
    END;
    outMod := PROJECT(nf, nf_to_mod(LEFT));
    RETURN outMod;
  END;
  /**
    * Get a single record (cell) from a model by index.
    *
    * @param mod The model (DATASET(layout_model2)) from which to extract the cell.
    * @param indxs The id of the cell to extract (e.g. [3,1,5]).
    * @param wi_num The work-item number to extract the cell from, default = 1.
    * @return The model cell (Layout_Model2) or an empty cell (wi=0) if not found.
    *
    */
  EXPORT Layout_Model2 GetItem(DATASET(Layout_Model2) mod, t_indexes indxs, wi_num=1) := FUNCTION
    RETURN mod(indexes=indxs AND wi=wi_num)[1];
  END;
  /**
    * Add a single record (cell) to an model at a given set of coordinates.
    *
    * @param mod The model to which to add a cell.
    * @param wi The work-item associated with the cell.
    * @param indexes The indices for the cell.
    * @param value The value of the cell.
    * @return Model with the added cell.
    *
    */
  EXPORT DATASET(Layout_Model2) SetItem(DATASET(Layout_Model2) mod, t_work_item wi, t_indexes indexes, t_fieldReal value) := FUNCTION
    RETURN mod + DATASET([{wi, value, indexes}], Layout_Model2);
  END;
END;
