lib: rec {
  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) {};

  # returns an attrset of all packages defined by input flakes
  # flattening them and renaming default packages
  genPackageOverlays = system: flakes: let
    renameDefault = flakeName: packages: (
      let
        hasDefault = builtins.hasAttr "default" packages;
        hasSelf = builtins.hasAttr flakeName packages;
        default =
          if hasDefault
          then packages.default
          else null;
        others =
          if hasDefault
          then removeAttrs packages [ "default" ]
          else null;
      in
        if hasDefault
        then
          if hasSelf
          then { "${flakeName}_default" = default; } // others
          else { ${flakeName} = default; } // others
        else packages
    );
    flatten = flakes: lib.pipe flakes [
      (lib.filterAttrs (_: builtins.hasAttr "packages"))
      (builtins.mapAttrs (_: flake: flake.packages.${system}))
      (builtins.mapAttrs renameDefault)
      builtins.attrValues
      updates
    ];
  in (_: _: flatten flakes);

  # returns an attrset with modules namespaced by flake name
  joinHmModules = builtins.mapAttrs (k: v: v.homeManagerModules);
}
