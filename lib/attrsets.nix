{ lib }:
let
  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) { };
  recursiveUpdates = builtins.foldl' (lib.recursiveUpdate) { };

  deepMergeAttrs = attrList:
    let
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
    in recurse [ ] attrList;

  # map reduce one level of key by name, returning original values
  # if it is not an attrset or doesn't have the key
  thruAttr = attr: it:
    if lib.isAttrs it && it ? ${attr} then it.${attr} else it;
  mapThruAttr = attr: lib.mapAttrs (name: thruAttr attr);
in {
  #
  inherit updates recursiveUpdates deepMergeAttrs thruAttr mapThruAttr;
}
