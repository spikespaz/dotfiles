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

  mkHost = args@{ inputs, ... }:
    setup@{
    # the system to use for the host platform
    system ? "x86_64-linux",
    # the branch of nixpkgs to use for the host
    nixpkgs ? inputs.nixpkgs,
    # arguments to be given to
    # <https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/impure.nix>
    nixpkgsArgs ? { }, overlays ? [ ],
    # additional specialArgs (overwrites args attrs)
    specialArgs ? { },
    # host component modules
    modules ? [ ] }:
    let
      setupStripped =
        removeAttrs setup [ "nixpkgs" "nixpkgsArgs" "overlays" "specialArgs" ];
    in nixpkgs.lib.nixosSystem (setupStripped // {
      pkgs = import nixpkgs ({ inherit system overlays; } // nixpkgsArgs);
      specialArgs = args // specialArgs // { inherit nixpkgs system; };
    });

  mkHome = args@{ inputs, ... }:
    setup@{
    # the system to use for the host platform
    system ? "x86_64-linux",
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
    modules ? [ ] }:
    let
      setupStripped = removeAttrs setup [
        "system"
        "nixpkgs"
        "nixpkgsArgs"
        "overlays"
        "homeManager"
        "extraSpecialArgs"
      ];
      lib = (if args ? lib then args.lib else nixpkgs.lib).extend (final: _: {
        hm = import "${homeManager}/modules/lib" { lib = final; };
      });
    in homeManager.lib.homeManagerConfiguration (setupStripped // {
      pkgs = import nixpkgs ({ inherit system overlays; } // nixpkgsArgs);
      extraSpecialArgs = args // extraSpecialArgs // {
        inherit nixpkgs system lib;
      };
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
  inherit mkFlakeTree mkFlakeSystems mkJoinedOverlays mkHost mkHome mkDirEntry;
}