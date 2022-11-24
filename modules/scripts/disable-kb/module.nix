{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  deviceFds = map (name: "/dev/${name}") (builtins.attrNames cfg.disableDevices);
  scriptBin = pkgs.writeShellScriptBin "wayland-disable-keyboard" ''
    export PATH='/run/wrappers/bin:${lib.makeBinPath (with pkgs; [
      bash
      coreutils
      dbus
      libnotify
      evtest
    ])}'
    export DISABLE_DEVICES='${lib.concatStringsSep ":" deviceFds}'
    ${
      builtins.replaceStrings [
        "toggle_script=\"$here/toggle_kb.sh\""
      ] [
        "toggle_script='${./toggle_kb.sh}'"
      ] (builtins.readFile ./disable_kb.sh)
    }
  '';
  cfg = config.desktopScripts.disableKeyboard;
in {
  options = {
    desktopScripts.disableKeyboard = {
      enable = lib.mkEnableOption (lib.mdDoc '''');
      allowedUsers = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [];
        description = lib.mdDoc '''';
        example = lib.literalExpression '''';
      };
      allowedGroups = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [];
        description = lib.mdDoc '''';
        example = lib.literalExpression '''';
      };
      disableDevices = lib.mkOption {
        type = types.attrsOf types.attrs;
        default = [];
        description = lib.mdDoc '''';
        example = lib.literalExpression '''';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [scriptBin];

    services.udev.extraRules = (
      lib.concatStringsSep "\n" (
        builtins.attrValues (
          builtins.mapAttrs (name: {
            product,
            vendor,
          }: ''
            SUBSYSTEMS=="input", ATTRS{id/product}=="${product}", ATTRS{id/vendor}=="${vendor}", SYMLINK+="${name}"
          '')
          cfg.disableDevices
        )
      )
    );

    security.sudo.extraRules = [
      {
        users = cfg.allowedUsers;
        groups = cfg.allowedGroups;
        commands = [
          {
            command = "${./toggle_kb.sh}";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
