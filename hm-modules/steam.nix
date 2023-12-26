{ lib, pkgs, config, ... }:
let
  inherit (lib) types;

  protonPackages = config.programs.steam.protonPackages;
  gloriousEggrolls = config.programs.steam.protonGE.versions;

  fetchProtonGE = version: hash:
    let name = "GE-Proton${version}";
    in pkgs.fetchzip {
      inherit name hash;
      url =
        "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${name}/${name}.tar.gz";
    };
in {
  options = {
    programs.steam.protonPackages = lib.mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
    programs.steam.protonGE = {
      versions = lib.mkOption {
        type = types.attrsOf (types.singleLineStr);
        default = { };
      };
    };
  };

  config = {
    xdg.dataFile = lib.mapListToAttrs (package: {
      name = "Steam/compatibilitytools.d/${package.name}";
      value = {
        recursive = true;
        source = package.outPath;
      };
    }) protonPackages;

    programs.steam.protonPackages =
      lib.mapAttrsToList (ver: hash: fetchProtonGE ver hash) gloriousEggrolls;
  };
}
