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

  # Takes a directory and a deny clause, and imports each file or directory
  # based on rules. An attribute set of the imported expressions is returned,
  # named according to each file with the `.nix` suffix removed.
  #
  # Your deny clause is turned into a predicate.
  # See the type checking in source.
  #
  # The rules for importing are:
  #  1. Is a regular file ending with `.nix`.
  #  2. Is a directory containing the regular file `default.nix`.
  #  3. Your predicate, given `name` and `type`, returns `true`.
  importDir = dir: deny:
    let
      inherit (lib) types;
      pred = # #
        if deny == null then
          (_: _: true)
        else if types.singleLineStr.check deny then
        # A single string is assumed to be a file name to be excluded.
          (name: type: !(type == "regular" && name == deny))
        else if lib.isFunction deny then
        # Basic predicate.
          deny
        else if (types.listOf types.singleLineStr).check deny then
        # A list of strings is assumed to be files
        # and directory names to exclude.
          (name: type: !(builtins.elem name deny))
        else if (types.listOf types.function).check deny then
        # Multiple predicates in a list, join them.
          (name: type: lib.birdos.mkJoinedOverlays deny)
        else
          throw
          "importDir predicate should be a string, function, or list of strings or functions";
      isNix = name: type:
        (type == "regular" && lib.hasSuffix ".nix" name)
        || (lib.pathIsRegularFile "${dir}/${name}/default.nix");
      pred' = name: type: (isNix name type) && (pred name type);
    in lib.pipe dir [
      builtins.readDir
      (lib.filterAttrs pred')
      (lib.mapAttrs' (name: _: {
        name = lib.removeSuffix ".nix" name;
        value = import "${dir}/${name}";
      }))
    ];
in {
  #
  inherit updates recursiveUpdates getAttrDefault getAttr thruAttr mapThruAttr
    mapListToAttrs attrPaths importDir;
}
