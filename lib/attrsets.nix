{ lib }:
let
  # Take a list of attribute sets, flatly updating them all into one.
  updates = builtins.foldl' (a: b: a // b) { };

  # Take a list of attribute sets, recursively updating them into one.
  recursiveUpdates = builtins.foldl' (lib.recursiveUpdate) { };

  # FIXME doc
  getAttrDefault = default: attrName: attrs:
    if attrs ? ${attrName} then attrs.${attrName} else default;

  # FIXME doc
  getAttr = getAttrDefault null;

  # TODO doc or remove
  thruAttr = attrName: attrs:
    if lib.isAttrs attrs && attrs ? ${attrName} then
      attrs.${attrName}
    else
      attrs;

  # TODO doc or remove
  mapThruAttr = attrName: lib.mapAttrs (name: thruAttr attrName);

  # TODO doc or remove
  mapListToAttrs = fn: attrsList: builtins.listToAttrs (map fn attrsList);

  # Return a list of attribute paths of every deepest non-attriibute-set value.
  attrPaths = attrs:
    let
      recursePaths = path:
        builtins.mapAttrs (name: value:
          if lib.isAttrs value then
            recursePaths (path ++ [ name ]) value
          else
            path ++ [ name ]);
      reduceValues = val:
        if lib.isList val then
          map (it:
            if lib.isAttrs it then
              reduceValues (builtins.attrValues it)
            else
              it) val
        else
          val;
    in lib.pipe attrs [
      (recursePaths [ ])
      lib.toList
      reduceValues
      (lib.flattenCond (builtins.any lib.isList))
    ];
in {
  #
  inherit updates recursiveUpdates getAttrDefault getAttr thruAttr mapThruAttr
    mapListToAttrs attrPaths;
}
