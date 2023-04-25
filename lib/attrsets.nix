{ lib, ... }:
let
  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) { };

  mergeAttrs = attrList:
    (let
      recurse = attrPath:
        lib.zipAttrsWith (n: values:
          (if lib.tail values == [ ] then
            lib.head values
          else if lib.all lib.isList values then
            lib.unique (lib.concatLists values)
          else if lib.all lib.isAttrs values then
            recurse (attrPath ++ [ n ]) values
          else
            lib.last values));
    in recurse [ ] attrList);
in { inherit updates deepMergeAttrs; }
