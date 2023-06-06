{ lib }:
let
  mkFlakeTree = path:
    lib.pipe (builtins.readDir path) [
      (lib.mapAttrsToList (name: type:
        let it = mkDirEntry path name type;
        in if it.isNix then it else null))
      (builtins.filter (x: !(isNull x)))
      (map (it: {
        name =
          if it.isNixFile then lib.removeSuffix ".nix" it.name else it.name;
        value = if it.isNixFile then
          import it.path
          ## commented out to fallthrough, will expose
          ## `default.nix` as `default` attr
          # else if it.isDir && it.hasDefault then
          #   import it.path
        else if it.isDir && it.hasNixFiles then
          mkFlakeTree it.path
        else
          abort lib.traceValM "unchecked direntry:" it;
      }))
      builtins.listToAttrs
    ];

  mkFlakeSystems = matrix:
    lib.pipe matrix [
      (map (lib.applyArgs lib.intersectLists))
      lib.concatLists
    ];

  mkJoinedOverlays = overlays: final: prev:
    lib.foldl' (attrs: overlay: attrs // (overlay final prev)) { } overlays;

  mkUnfreeOverlay = prev: paths:
    lib.pipe paths [
      (map (path: {
        inherit path;
        value = lib.getAttrFromPath path prev;
      }))
      (map (it:
        lib.setAttrByPath it.path (it.value.overrideAttrs (old:
          lib.recursiveUpdate old {
            meta.license = (if builtins.isList old.meta.license then
              map (_: { free = true; }) old.meta.license
            else {
              free = true;
            });
          }))))
      (lib.foldl' lib.recursiveUpdate { })
    ];

  mkHost = args@{ inputs, ... }:
    setup@{
    # The platform on which packages will be run (built for).
    # Will be used as the default platform for the other two settings.
    # Will be used for `targetPlatform`.
    hostPlatform,
    # The platform on which to build packages.
    # This is different from `localPlatform`.
    buildPlatform ? hostPlatform,
    # The platform of the hardware running the build.
    localPlatform ? buildPlatform,
    # The input of nixpkgs to use for the host.
    nixpkgs ? inputs.nixpkgs,
    # Arguments to be given to nixpkgs instantiation.
    # <https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/impure.nix>
    nixpkgsArgs ? { }, overlays ? [ ],
    # Additional `specialArgs` (overwrites `args` attributes).
    specialArgs ? { },
    # Most component modules to merge.
    modules ? [ ],
    # additional arguments are passed through
    ... }:

    let ownArgs = builtins.attrNames (builtins.functionArgs (mkHost args));
    in nixpkgs.lib.nixosSystem ((removeAttrs setup ownArgs) // {
      modules = modules ++ [{ config.nixpkgs.hostPlatform = hostPlatform; }];
      pkgs = import nixpkgs ({
        inherit overlays;
        localSystem = localPlatform;
        crossSystem = hostPlatform;
      } // nixpkgsArgs);
      specialArgs = args // specialArgs // { inherit nixpkgs; };
    });

  mkHome = args@{ inputs, ... }:
    setup@{
    # The platform on which packages will be run (built for).
    # Will be used as the default platform for the other two settings.
    # Will be used for `targetPlatform`.
    hostPlatform,
    # The platform on which to build packages.
    # This is different from `localPlatform`.
    buildPlatform ? hostPlatform,
    # The platform of the hardware running the build.
    localPlatform ? buildPlatform,
    # the branch of nixpkgs to use for the environment
    nixpkgs ? inputs.nixpkgs,
    # arguments to be given to
    # <https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/impure.nix>
    nixpkgsArgs ? { }, overlays ? [ ],
    # home manager flake
    homeManager ? inputs.home-manager,
    # additional specialArgs (overwrites args attrs)
    extraSpecialArgs ? { },
    # host component modules
    modules ? [ ],
    # additional arguments are passed through
    ... }:
    let
      ownArgs = builtins.attrNames (builtins.functionArgs (mkHome args));
      lib = (if args ? lib then args.lib else nixpkgs.lib).extend (final: _: {
        hm = import "${homeManager}/modules/lib" { lib = final; };
      });
    in homeManager.lib.homeManagerConfiguration ((removeAttrs setup ownArgs)
      // {
        inherit modules;
        pkgs = import nixpkgs ({
          inherit overlays;
          localSystem = localPlatform;
          crossSystem = hostPlatform;
        } // nixpkgsArgs);
        extraSpecialArgs = args // extraSpecialArgs // { inherit nixpkgs lib; };
      });

  mkDirEntry = dirname: basename: type: rec {
    inherit type;
    name = basename;
    path = "${dirname}/${basename}";

    isHidden = lib.hasPrefix "." name;
    isFile = type == "regular";
    isDir = type == "directory";
    isProject = !isHidden && (isFile || isDir);
    isNixFile = isFile && lib.hasSuffix ".nix" name;
    hasDefault = let ls = builtins.readDir "${path}";
    in ls ? "default.nix" && ls."default.nix" == "regular";
    hasNixFiles =
      let ls = lib.mapAttrsToList (mkDirEntry path) (builtins.readDir path);
      in builtins.any (it: it.isNixFile || (it.isDir && it.hasNixFiles)) ls;
    isNix = isProject && (isNixFile || (isDir && hasNixFiles));
  };
in {
  #
  inherit mkFlakeTree mkFlakeSystems mkJoinedOverlays mkUnfreeOverlay mkHost
    mkHome mkDirEntry;
}
