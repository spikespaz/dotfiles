{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.utilities.osd-functions;

  description = ''
    Shell script providing functions to change device settings while
    showing an on-screen display (with Dunst).
  '';

  rePatterns = builtins.mapAttrs (p: "^(${p})$") {
    hexColor = "#[0-9a-fA-F]{6}";
    fontSize = "[0-9]+(\\.[0-9]+)?pt|[0-9]+%";
  };

  typePercentageFloat = lib.mkOptionType {
    name = "float";
    description = "floating point number as a percentage";
    descriptionClass = "noun";
    check = x: lib.isFloat x && x >= 0;
    inherit (types.float) merge;
  };

  mkIconOption = {
    actionName,
    default,
  }:
    lib.mkOption {
      type = types.either types.singleLineStr types.path;
      inherit default;
      description = lib.mdDoc ''
        The icon to display on ${actionName},
        either a string containing the name of the icon
        to use from `${cfg}.notification.iconsDir`,
        or a path to a valid icon file (vector or raster).
        Icon file types must be supported by `notify-send`.
      '';
    };
in {
  options = {
    utilities.osd-functions = {
      settings = {
        notification = {
          duration = lib.mkOption {
            type = types.ints.positive;
            default = 700;
            description = lib.mdDoc ''
              The duration (in milliseconds) for which
              to show the OSD notification.
            '';
          };
          urgency = lib.mkOption {
            type = types.enum ["low" "normal" "critical"];
            default = "normal";
            description = lib.mdDoc ''
              The urgency level to use for the notification.
              This can determine, for example: order, duration, and styling.
            '';
          };
          mainTextSize = lib.mkOption {
            type =
              types.either
              (types.enum [
                "xx-small"
                "x-small"
                "small"
                "medium"
                "large"
                "x-large"
                "xx-large"
              ])
              (types.strMatching rePatterns.fontSize);
            default = "x-large";
            description = lib.mdDoc ''
              The font size of the main OSD text.
              Can be an absolute size, for example `x-large`,
              or a point size, `32.5pt`, or a percentage, `200%`.
            '';
          };
          iconsDir = lib.mkOption {
            type = types.path;
            default = ./icons/rounded-white;
            description = lib.mdDoc ''
              The root path to use when assigning icon paths.
            '';
          };
          colors = {
            highlightNormal = lib.mkOption {
              type = types.strMatching rePatterns.hexColor;
              default = "#00ff00";
              description = lib.mdDoc ''
                Color to use for highlights when the subject is "normal" state.
              '';
            };
            highlightWarning = lib.mkOption {
              type = types.strMatching rePatterns.hexColor;
              default = "#00ff00";
              description = lib.mdDoc ''
                Color to use for highlights when the subject is "warning" state.
              '';
            };
          };
        };

        audioOutput = {
          maxVolume = lib.mkOption {
            type = typePercentageFloat;
            default = 1.0;
            description = lib.mdDoc ''
              The maximum volume to allow for the output device.
              This value is a percentage, expressed as a float greater than zero.
            '';
          };
          notification = {
            title = lib.mkOption {
              type = types.singleLineStr;
              default = "Default Audio Output";
              description = lib.mdDoc ''
                The notification title to display for audio output actions.
              '';
            };
            icons = {
              enable = mkIconOption {
                actionName = "output device enable";
                default = "volume_up_white_36dp.svg";
              };
              disable = mkIconOption {
                actionName = "output device disable";
                default = "volume_off_white_36dp.svg";
              };
              increase = mkIconOption {
                actionName = "output volume increase";
                default = "volume_up_white_36dp.svg";
              };
              decrease = mkIconOption {
                actionName = "output volume decrease";
                default = "volume_down_white_36dp.svg";
              };
            };
          };
        };

        audioInput = {
          deviceNode = lib.mkOption {
            type =
              types.either
              types.ints.positive
              (types.strMatching "^(@DEFAULT_AUDIO_SINK@)$");
            default = "@DEFAULT_AUDIO_SINK@";
            description = lib.mdDoc ''
              WirePlumber's device node ID for the input (source)
              device you would like this group of actions to control.

              You can get the IDs for your devices by running
              `wpctl status` and looking at the numbers to the left of
              your device names in the **Sources** section under **Audio**.

              Use `@DEFAULT_AUDIO_SINK@` for the fallback (default) device.
            '';
          };
          notification = {
            title = lib.mkOption {
              type = types.singleLineStr;
              default = "Default Audio Input";
              description = lib.mdDoc ''
                The notification title to display for audio input actions.
              '';
            };
            icons = {
              enable = mkIconOption {
                actionName = "input device enable";
                default = "volume_up_white_36dp.svg";
              };
              disable = mkIconOption {
                actionName = "input device disable";
                default = "volume_off_white_36dp.svg";
              };
            };
          };
        };
      };
    };
  };

  config = {};
}
