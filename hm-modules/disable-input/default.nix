{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  inherit (import ./common.nix) baseName version src;
  optionName = baseName;
  cfg = config.programs.${optionName};
in {
  options = {
    programs.${optionName} = {
      enable = lib.mkEnableOption (lib.mdDoc "");
      delay = lib.mkOption {
        type = types.ints.positive;
        default = 2000;
        description = lib.mdDoc ''
          Delay in millseconds to wait before disabling input devices.
          This option is provided because when triggered via keybind,
          the keys pressed can get "stuck" after re-enabling devices.
        '';
        example = lib.literalExpression "2500";
      };
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
          example = lib.literalExpression ''"200%"'';
        };
        iconCategory = lib.mkOption {
          type = types.nullOr types.singleLineStr;
          default = null;
          description = lib.mdDoc ''
            The icon category to select `iconName` from for the current
            user session's icon theme.
          '';
          example = lib.literalExpression ''"apps"'';
        };
        iconName = lib.mkOption {
          type = types.oneOf [ types.singleLineStr types.path ];
          default =
            "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/devices/keyboard-input.svg";
          description = lib.mdDoc ''
            The name of the icon (in `iconCategory`) to use from
            the current user session's icon theme.
            This can also be a path to an icon if `iconCategory` is null.
          '';
          example = lib.literalExpression ''"computerjanitor"'';
        };
        urgency = lib.mkOption {
          type = types.enum [ "low" "normal" "critical" ];
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
          example = lib.literalExpression ''"Pause Device Input"'';
        };
      };
    };
  };
  config = lib.mkIf cfg.enable (let
    package = pkgs.stdenv.mkDerivation {
      pname = "${baseName}-notify";
      inherit version src;

      strictDeps = true;
      nativeBuildInputs = [ pkgs.makeWrapper ];

      installPhase = let
        scriptName = "${baseName}-notify";
        scriptPath = "/run/wrappers/bin:"
          + lib.makeBinPath (with pkgs; [ bash coreutils bc dbus libnotify ]);
      in ''
        install -Dm755 disable-devices-notify.sh $out/bin/${scriptName}

        sed -i \
          "s;toggle_script=.\+;toggle_script='/run/current-system/sw/bin/${baseName}';" \
          $out/bin/${scriptName}

        wrapProgram $out/bin/${scriptName} \
          --set PATH '${scriptPath}'
      '';
    };
    wrappedPackage = package.overrideAttrs (old: {
      postFixup = ''
        wrapProgram $out/bin/${old.pname} \
          --set DISABLE_DELAY '${toString cfg.delay}' \
          --set DISABLE_DURATION '${toString cfg.duration}' \
          --set NOTIFICATION_COUNTDOWN '${
            toString cfg.notification.countdown
          }' \
          --set NOTIFICATION_TIMEOUT '${toString cfg.notification.timeout}' \
          --set NOTIFICATION_TEXT_SIZE '${toString cfg.notification.textSize}' \
          --set NOTIFICATION_ICON_CATEGORY '${
            toString cfg.notification.iconCategory
          }' \
          --set NOTIFICATION_ICON_NAME '${toString cfg.notification.iconName}' \
          --set NOTIFICATION_URGENCY '${cfg.notification.urgency}' \
          --set NOTIFICATION_TITLE '${cfg.notification.title}'
      '';
    });
  in { home.packages = [ wrappedPackage ]; });
}
