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
        description = lib.mdDoc ''
          Duration in seconds to temporarily disable input devices.
        '';
        example = lib.literalExpression "60";
      };
      notification = {
        countdown = lib.mkOption {
          type = types.ints.positive;
          default = cfg.duration - 2;
          description = lib.mdDoc ''
            Duration in seconds to countdown before enabling input devices.
            One notification is shown for each second of the countdown,
            with a progress bar decreasing until zero.
          '';
          example = lib.literalExpression "55";
        };
        timeout = lib.mkOption {
          type = types.ints.positive;
          default = 2500;
          description = lib.mdDoc ''
            The timeout in milliseconds before the last notification
            (that says devices are enabled) disappears.
          '';
          example = lib.literalExpression "5000";
        };
        textSize = lib.mkOption {
          type = types.singleLineStr;
          default = "x-large";
          description = lib.mdDoc ''
            The size of the text in the first line of begin and end notifications.
            Pango markup `text_size` attribute:
            <https://docs.gtk.org/Pango/pango_markup.html#the-span-attributes>
          '';
          example = lib.literalExpression "\"200%\"";
        };
        iconCategory = lib.mkOption {
          type = types.nullOr types.singleLineStr;
          default = null;
          description = lib.mdDoc ''
            The icon category to select `iconName` from for the current
            user session's icon theme.
          '';
          example = lib.literalExpression "\"apps\"";
        };
        iconName = lib.mkOption {
          type = types.oneOf [types.singleLineStr types.path];
          default = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/devices/keyboard-input.svg";
          description = lib.mdDoc ''
            The name of the icon (in `iconCategory`) to use from
            the current user session's icon theme.
            This can also be a path to an icon if `iconCategory` is null.
          '';
          example = lib.literalExpression "\"computerjanitor\"";
        };
        urgency = lib.mkOption {
          type = types.enum ["low" "normal" "critical"];
          default = "normal";
          description = lib.mdDoc ''
            The urgency of the notifications.
            Read about this from your notification daemon's manual.
          '';
          example = lib.literalExpression "";
        };
        title = lib.mkOption {
          type = types.singleLineStr;
          default = "Input/Keyboard";
          description = lib.mdDoc ''
            The title to use for all three norification types.
          '';
          example = lib.literalExpression "\"Pause Device Input\"";
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
