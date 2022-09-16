lib: rec {
  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) {};
  # function to make using input flakes more ergonomic
  # renames attrs and updates og back on top
  flatFlake = flake: system: updates [
    (lib.optionalAttrs (builtins.hasAttr "packages" flake)
      { pkgs = flake.packages.${system}; })
    (lib.optionalAttrs (builtins.hasAttr "homeManagerModules" flake)
      { hmModules = flake.homeManagerModules; })
    flake
  ];
  # same as above but with an attrset of named flake inputs
  flatFlakes = system: builtins.mapAttrs (_: f: flatFlake f system);
  # spoof the license of every package
  spoofAllowUnfree = maybe: flake: (
    if maybe
    then lib.recursiveUpdate flake {
      # this works for system config
      nixpkgs.config.allowUnfree = maybe;
      # there is a bug in nixpkgs that prevents the global
      # "allowUnfree" from working, so instead just specify
      # a callback that says yes every time something asks
      # if it can install a package with a proprietary license
      # <https://github.com/nix-community/home-manager/issues/2942>
      nixpkgs.config.allowUnfreePredicate = _: maybe;
      # spoof the licenses for local flake packages
      packages =
        builtins.mapAttrs (_: system:
          builtins.mapAttrs (_: package:
            package.overrideAttrs (old: {
              meta.license =
                old.meta.license // { free = true; };
            })
          ) system
        ) flake.packages;
    }
    else flake
  );
}
