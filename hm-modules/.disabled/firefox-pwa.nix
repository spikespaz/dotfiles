{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  cfg = config.programs.firefox.pwa;
in {
  options = {
    programs.firefox.pwa = {
      enable = lib.mkEnableOption (lib.mdDoc "enable");
      package = lib.mkOption {
        type = types.package;
        default = pkgs.firefox-pwa;
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
      firefoxPackage = lib.mkOption {
        type = types.package;
        default = pkgs.firefox;
        description = lib.mdDoc ''
          Please use this option instead of Home Manager's
          `programs.firefox.package`, as the package provided here is wrapped
          again with environment variables necessary for the PWAs
          extension to function.

          **The value of this option is assigned to `programs.firefox.package`
          after being wrapped.**
        '';
        example = lib.literalExpression ''
          pkgs.firefox-esr
        '';
      };
      executables = lib.mkOption {
        type = types.path;
        readOnly = true;
        default = "${cfg.package}/bin";
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
      sysData = lib.mkOption {
        type = types.path;
        readOnly = true;
        default = "${cfg.package}/share/firefoxpwa";
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
      userData = lib.mkOption {
        type = types.path;
        default = "${config.xdg.dataHome}/firefoxpwa";
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      FFPWA_EXECUTABLES = cfg.executables;
      FFPWA_SYSDATA = cfg.sysData;
      FFPWA_USERDATA = cfg.userData;
    };
    programs.firefox.package = cfg.firefoxPackage.overrideAttrs (self: super: {
      nativeBuildInputs = (super.nativeBuildInputs or [ ])
        ++ [ pkgs.makeWrapper ];
      postFixup = ''
        wrapProgram ${lib.getExe cfg.firefoxPackage} \
          --set FFPWA_EXECUTABLES '${cfg.executables}' \
          --set FFPWA_SYSDATA '${cfg.sysData}' \
          --set FFPWA_USERDATA '${cfg.userData}'
      '';
    });
    home.file.".mozilla/native-messaging-hosts/firefoxpwa.json".source =
      "${cfg.package}/lib/mozilla/native-messaging-hosts/firefoxpwa.json";
    home.packages = [ cfg.package ];
  };
}
