{lib, config, ...}:
  let
    inherit (lib) mkOption types;
  in
{
  options = {
    userPackages = mkOption {
      type = types.attrsOf (types.listOf types.package);
    };
  };
  config = {
    home.packages = builtins.concatLists (builtins.attrValues config.userPackages);
  };
}
