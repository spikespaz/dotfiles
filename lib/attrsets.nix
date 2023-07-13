{ lib }:
let
  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) { };
  recursiveUpdates = builtins.foldl' (lib.recursiveUpdate) { };

  # map reduce one level of key by name, returning original values
  # if it is not an attrset or doesn't have the key
  thruAttr = attr: it:
    if lib.isAttrs it && it ? ${attr} then it.${attr} else it;
  mapThruAttr = attr: lib.mapAttrs (name: thruAttr attr);

  mapListToAttrs = fn: xs: builtins.listToAttrs (map fn xs);
in {
  #
  inherit updates recursiveUpdates thruAttr mapThruAttr mapListToAttrs;
}
