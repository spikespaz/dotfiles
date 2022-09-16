lib: rec {
  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) {};

  # rename attributes whose name is default,
  # if no default exists the attrs will be untouched
  # if there is a default and no attr matching newName,
  # the default attr will be renamed to newName
  # if there is a default and an arrt matching newName,
  # the default attr will be renamed to ${newName}_default
  # and default will be renamed to newName
  renameDefaultAttr = newName: attrs: (
    let
      hasDefault = builtins.hasAttr "default" attrs;
      hasNewName = builtins.hasAttr newName attrs;
      default =
        if hasDefault
        then attrs.default
        else null;
      others =
        if hasDefault
        then removeAttrs attrs [ "default" ]
        else null;
    in
      if hasDefault
      then
        if hasNewName
        then { "${newName}_default" = default; } // others
        else { ${newName} = default; } // others
      else attrs
  );

  # flatten and join inputs by attrPath,
  # which is a list of attr names used as accessors
  # any attrs named default in the value of the attr which is accessed
  # using the last elem in attrPath will be renamed
  # to the value of the previous segment
  # it is recommended to filter the inputs
  # beforehand to ensure that any malformed values are ignored,
  # if applicable
  genJoinedUnits = attrPath: inputs: let
    flatten = inputs: lib.pipe inputs [
      (builtins.mapAttrs (_: lib.getAttrFromPath attrPath))
      (builtins.mapAttrs renameDefaultAttr)
      builtins.attrValues
      updates
    ];
  in (flatten inputs);

  # returns an attrset of all packages defined by input flakes
  # flattening them and renaming default packages
  genPackageOverlays = system: flakes: let
    flatten = flakes: lib.pipe flakes [
      (lib.filterAttrs (_: builtins.hasAttr "packages"))
      (genJoinedUnits [ "packages" system ])
    ];
  in (_: _: flatten flakes);

  joinNixosModules = flakes: let
    flatten = flakes: lib.pipe flakes [
      (lib.filterAttrs (_: builtins.hasAttr "nixosModules"))
      (genJoinedUnits [ "nixosModules" ])
    ];
  in (flatten flakes);

  joinHmModules = flakes: let
    flatten = flakes: lib.pipe flakes [
      (lib.filterAttrs (_: builtins.hasAttr "homeManagerModules"))
      (genJoinedUnits [ "homeManagerModules" ])
    ];
  in (flatten flakes);
}
