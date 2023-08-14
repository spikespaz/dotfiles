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

  # systems = with lib.systems.doubles;
  #   lib.birdos.mkFlakeSystems [
  #     [ x86_64 linux ]
  #     [ arm linux ]
  #     [ aarch64 linux ]
  #     [ arm darwin ]
  #     [ aarch64 darwin ]
  #   ];
  mkFlakeSystems = matrix:
    lib.pipe matrix [
      (map (lib.applyArgs lib.intersectLists))
      lib.concatLists
    ];

  mkJoinedOverlays = overlays: pkgs: pkgs0:
    lib.foldl' (attrs: overlay: attrs // (overlay pkgs pkgs0)) { } overlays;

  mkUnfreeOverlay = pkgs: pkgs0:
    lib.pipe pkgs0 [
      (map (path: {
        inherit path;
        value = lib.getAttrFromPath path pkgs;
      }))
      (map (it:
        lib.setAttrByPath it.path (it.value.overrideAttrs (self: super:
          lib.recursiveUpdate super {
            meta.license = (if builtins.isList super.meta.license then
              map (_: { free = true; }) super.meta.license
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
    # Will also be used for `targetPlatform`.
    hostPlatform,
    # The platform on which to build packages.
    # This is different from `localPlatform`.
    buildPlatform ? hostPlatform,
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

    let
      ownArgs = builtins.attrNames (builtins.functionArgs (mkHost args));
      pkgs = import nixpkgs ({
        inherit overlays;
        localSystem = buildPlatform;
        # This does not work due to a litany of problems with platform comparisons
        # <https://github.com/NixOS/nixpkgs/pull/237512>
        # <https://github.com/NixOS/nixpkgs/pull/238136>
        # <https://github.com/NixOS/nixpkgs/pull/238331>
        # crossSystem = hostPlatform;
      } // (lib.optionalAttrs (!lib.systems.equals hostPlatform buildPlatform) {
        crossSystem = hostPlatform;
      }) // nixpkgsArgs);
    in nixpkgs.lib.nixosSystem ((removeAttrs setup ownArgs) // {
      modules = [{ nixpkgs.pkgs = pkgs; }] ++ modules;
      specialArgs = args // specialArgs // { inherit nixpkgs; };
    });

  mkHome = args@{ inputs, ... }:
    setup@{
    # The platform on which packages will be run (built for).
    # Will be used as the default platform for the other two settings.
    # Will also be used for `targetPlatform`.
    hostPlatform,
    # The platform on which to build packages.
    # This is different from `localPlatform`.
    buildPlatform ? hostPlatform,
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
          localSystem = buildPlatform;
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
