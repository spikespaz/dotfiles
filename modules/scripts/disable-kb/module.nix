{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  defaultPackage = pkgs.callPackage ./package.nix {};
  cfg = config.programs.wayland-disable-keyboard;
in {
  options = {
    programs.wayland-disable-keyboard = {
      enable = lib.mkEnableOption (lib.mdDoc '''');
      package = lib.mkOption {
        type = types.package;
        default = defaultPackage;
        description = lib.mdDoc '''';
        example = lib.literalExpression ''
          pkgs.wayland-disable-keyboard
        '';
      };
      disableDevices = lib.mkOption {
        type = types.attrsOf types.attrs;
        default = [];
        description = lib.mdDoc '''';
        example = lib.literalExpression '''';
      };
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
    };
  };
  config = lib.mkIf cfg.enable (
    let
      deviceFds = map (name: "/dev/${name}") (builtins.attrNames cfg.disableDevices);
      wrappedPackage = cfg.package.override {
        disableDevices = deviceFds;
      };
    in {
      environment.systemPackages = [wrappedPackage];

      services.udev.extraRules = (
        lib.concatStrings (
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
              command = "${cfg.package}/bin/disable-input-devices";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    }
  );
}
