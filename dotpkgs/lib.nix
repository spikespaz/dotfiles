lib: rec {
  mkSuffixedAttrsPaths = suffix: names: lib.pipe names [
    (map (name: {
      inherit name;
      value = ./. + "/${name}/${suffix}";
    }))
    builtins.listToAttrs
  ];

  mkPackages = pkgs: args: names: lib.pipe names [
    (mkSuffixedAttrsPaths "package.nix")
    (builtins.mapAttrs (_: p: lib.callPackageWith pkgs p args))
  ];

  mkModules = suffix: inputs: names: lib.pipe names [
    (mkSuffixedAttrsPaths suffix)
    (builtins.mapAttrs (_: m: import m inputs))
  ];

  mkNixosModules = mkModules "module.nix";
  mkHmModules = mkModules "hm-module.nix";

  # make an overlay lambda that overrides the license of every provided package
  # to spoof free-ness
  # returns an attrset where the keys are the pnames of each derivation
  mkUnfreeOverlay = packages: let
    overrides = lib.pipe packages [
      (map (value: { name = lib.getName value; inherit value; }))
      builtins.listToAttrs
      (builtins.mapAttrs (_: package: package.overrideAttrs (
        old: lib.recursiveUpdate old {
          meta.license = (
            if builtins.isList old.meta.license
            then map (_: { free = true; }) old.meta.license
            else { free = true; }
          );
        }
      )))
    ];
  in (_: _: overrides);
}
