lib: rec {
  mkSuffixedAttrsPaths = suffix: names:
    lib.pipe names [
      (map (name: {
        inherit name;
        value = ./. + "/${name}/${suffix}";
      }))
      builtins.listToAttrs
    ];
  mkPackages = pkgs: args: names:
    lib.pipe names [
      (mkSuffixedAttrsPaths "package.nix")
      (builtins.mapAttrs (_: p: lib.callPackageWith pkgs p args))
    ];
  mkModules = suffix: inputs: names:
    lib.pipe names [
      (mkSuffixedAttrsPaths suffix)
      (builtins.mapAttrs (_: m: import m inputs))
    ];
  mkNixosModules = mkModules "module.nix";
  mkHmModules = mkModules "hm-module.nix";
}
