lib: rec {
  mkSuffixedAttrsPaths = suffix: names:
    lib.pipe names [
      (map (name: {
        inherit name;
        value = ./. + "/${name}/${suffix}";
      }))
      builtins.listToAttrs
    ];
  mkPackages = pkgs: names:
    lib.pipe names [
      (mkSuffixedAttrsPaths "package.nix")
      (builtins.mapAttrs (_: p: pkgs.callPackage p {}))
    ];
  mkModules = suffix: inputs: names:
    lib.pipe names [
      (mkSuffixedAttrsPaths suffix)
      (builtins.mapAttrs (_: m: import m inputs))
    ];
  mkNixosModules = mkModules "module.nix";
  mkHmModules = mkModules "hm-module.nix";
}
