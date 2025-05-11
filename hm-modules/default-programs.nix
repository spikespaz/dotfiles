# TODO: This is a rough sketch, not sure if the precedence of default values is correct.
{ lib, ... }:
let
  mkDefaultProgramOption = default:
    lib.mkOption {
      type = with lib.types; either defaultProgramType singleLineStr;
      default = { exe = null; };
      apply = v: if lib.isDerivation v then { package = v; } else { exec = v; };
    };
  defaultProgramType = lib.types.submodule ({ config, ... }: {
    options = {
      exec = lib.mkOption {
        type = with lib.types; nullOr singleLineStr;
        default =
          if config.package != null then lib.getExe config.package else null;
        description = ''
          The command to execute (to start the program).
        '';
      };
      name = lib.mkOption {
        type = with lib.types; nullOr singleLineStr;
        default = # #
          if config.package != null
          && lib.hasAttrByPath [ "meta" "pname" ] config.package then
            config.package.meta.pname
          else if config.exec != null then
            baseNameOf config.exec
          else
            null;
      };
      package = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
      };
    };
  });
  perSessionType = lib.types.submodule ({ ... }: {
    options = {
      terminal = mkDefaultProgramOption null;
      browser = mkDefaultProgramOption null;
      fileManager = mkDefaultProgramOption null;
      calculator = mkDefaultProgramOption null;
    };
  });
in {
  options = {
    home.defaultPrograms =
      lib.mkOption { type = with lib.types; attrsOf perSessionType; };
  };
  config = { };
}
