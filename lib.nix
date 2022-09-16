lib: rec {
  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) {};
  # function to make using input flakes more ergonomic
  # renames attrs and updates og back on top
  flatFlake = flake: system: updates [
    (lib.optionalAttrs (builtins.hasAttr "packages" flake)
      { pkgs = flake.packages.${system}; })
    flake
  ];

  # same as above but with an attrset of named flake inputs
  flatFlakes = system: builtins.mapAttrs (_: f: flatFlake f system);
  # returns an attrset with modules namespaced by flake name
  joinHmModules = builtins.mapAttrs (k: v: v.homeManagerModules);
}
