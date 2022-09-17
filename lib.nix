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
    lib.mapAttrs' (name: value: {
      name =
        if name == "default"
        then
          if attrs ? ${newName}
          then "${newName}_default"
          else newName
        else name;
      inherit value;
    }) attrs
  );

  # flatten and join inputs by attrPath,
  # which is a list of attr names used as accessors
  # any attrs named default in the value of the attr which is accessed
  # using the last elem in attrPath will be renamed
  # to the value of the previous segment
  # it is recommended to filter the inputs
  # beforehand to ensure that any malformed values are ignored,
  # if applicable
  genJoinedUnits = attrPath: inputs: lib.pipe inputs [
    (builtins.mapAttrs (_: lib.getAttrFromPath attrPath))
    (builtins.mapAttrs renameDefaultAttr)
    builtins.attrValues
    updates
  ];

  # returns an attrset of all packages defined by input flakes
  # flattening them and renaming default packages
  mkPackagesOverlay = system: flakes: lib.pipe flakes [
    (lib.filterAttrs (_: attrs: attrs ? packages))
    (genJoinedUnits [ "packages" system ])
    (overrides: _: _: overrides)
  ];

  joinNixosModules = flakes: lib.pipe flakes [
    (lib.filterAttrs (_: attrs: attrs ? nixosModules))
    (genJoinedUnits [ "nixosModules" ])
  ];

  joinHmModules = flakes: lib.pipe flakes [
    (lib.filterAttrs (_: attrs: attrs ? homeManagerModules))
    (genJoinedUnits [ "homeManagerModules" ])
  ];
}
