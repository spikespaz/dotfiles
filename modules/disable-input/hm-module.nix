{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.programs.disable-input-devices;
in {
  options = {
    programs.disable-input-devices = {
      enable = lib.mkEnableOption (lib.mdDoc '''');
      duration = lib.mkOption {
        type = types.ints.positive;
        default = 30;
        description = lib.mdDoc '''';
        example = lib.literalExpression "";
      };
      notification = {
        countdown = lib.mkOption {
          type = types.ints.positive;
          default = cfg.duration - 2;
          description = lib.mdDoc '''';
          example = lib.literalExpression "";
        };
        timeout = lib.mkOption {
          type = types.ints.positive;
          default = 2500;
          description = lib.mdDoc '''';
          example = lib.literalExpression "";
        };
        textSize = lib.mkOption {
          type = types.enum ["x-large"];
          default = "x-large";
          description = lib.mdDoc '''';
          example = lib.literalExpression "";
        };
        iconCategory = lib.mkOption {
          type = types.nullOr types.singleLineStr;
          default = null;
          description = lib.mdDoc '''';
          example = lib.literalExpression "";
        };
        iconName = lib.mkOption {
          type = types.oneOf [types.singleLineStr types.path];
          default = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/devices/keyboard-input.svg";
          description = lib.mdDoc '''';
          example = lib.literalExpression "";
        };
        urgency = lib.mkOption {
          type = types.enum ["normal"];
          default = "normal";
          description = lib.mdDoc '''';
          example = lib.literalExpression "";
        };
        title = lib.mkOption {
          type = types.singleLineStr;
          default = "Input/Keyboard";
          description = lib.mdDoc '''';
          example = lib.literalExpression "";
        };
      };
    };
  };
  config = lib.mkIf cfg.enable (let
    binaryName = "disable-input-devices-notify";
    wrapperBin = pkgs.writeShellScriptBin binaryName ''
      export DISABLE_DURATION=${toString cfg.duration}
      export NOTIFICATION_COUNTDOWN=${toString cfg.notification.countdown}
      export NOTIFICATION_TIMEOUT=${toString cfg.notification.timeout}
      export NOTIFICATION_TEXT_SIZE=${toString cfg.notification.textSize}
      export NOTIFICATION_ICON_CATEGORY=${toString cfg.notification.iconCategory}
      export NOTIFICATION_ICON_NAME=${toString cfg.notification.iconName}
      export NOTIFICATION_URGENCY=${cfg.notification.urgency}
      export NOTIFICATION_TITLE='${cfg.notification.title}'

      /run/current-system/sw/bin/${binaryName}
    '';
  in {
    # TODO probably don't make so many assumptions
    home.packages = [wrapperBin];
  });
}
