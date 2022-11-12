{
  config,
  pkgs,
  lib,
  ...
}: let
  disableDevices = [
    # AT Translated Set 2 Keyboard
    "/dev/input/event0"
    # Sleep Button
    "/dev/input/event9"
    # Power Button
    "/dev/input/event10"
    # Lid Switch
    "/dev/input/event8"
    # ThinkPad Extra Buttons
    "/dev/input/event15"
    # SynPS/2 Synaptics Touchpad
    "/dev/input/event19"
    # TPPS/2 Elan TrackPoint
    "/dev/input/event21"
  ];
  disableDuration = 30;
  notification.countdown = 28;
  notification.timeout = 2000;
  notification.textSize = "x-large";
  notification.iconCategory = "";
  notification.iconName = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/devices/keyboard-input.svg";
  notification.urgency = "critical";
  notification.title = "Input/Keyboard";

  # script = pkgs.stdenv.mkDerivation {
  #   nativeBuildInputs = [pkgs.stdenv.wrapProgram];
  #   installPhase = ''
  #     mkdir -p $out/bin
  #     cp ${./disable_kb.sh} $out/bin/disable_kb

  #     wrapProgram $out/bin/disable_kb \
  #       --set PATH=${lib.makeBinPath (with pkgs; [su evtest libnotify])}
  #       --set DISABLE_DEVICES=(${
  #       builtins.foldl' (a: x: "${a} '${x}'") "" disableDevices
  #     }) \
  #       --set DISABLE_DURATION=${toString disableDuration} \
  #       --set NOTIFICATION_COUNTDOWN=${toString notification.countdown} \
  #       --set NOTIFICATION_TIMEOUT=${toString notification.timeout} \
  #       --set NOTIFICATION_TEXT_SIZE=${toString notification.textSize} \
  #       --set NOTIFICATION_ICON_CATEGORY=${notification.iconCategory} \
  #       --set NOTIFICATION_ICON_NAME=${toString notification.iconName} \
  #       --set NOTIFICATION_URGENCY=${notification.urgency} \
  #       --set NOTIFICATION_TITLE='${notification.title}'
  #   '';
  # };
  script = pkgs.writeShellScript ''disable-keyboard'' ''
    DISABLE_DEVICES=(${builtins.foldl' (a: x: "${a} '${x}'") "" disableDevices})
    DISABLE_DURATION=${toString disableDuration}
    NOTIFICATION_COUNTDOWN=${toString notification.countdown}
    NOTIFICATION_TIMEOUT=${toString notification.timeout}
    NOTIFICATION_TEXT_SIZE=${toString notification.textSize}
    NOTIFICATION_ICON_CATEGORY=${notification.iconCategory}
    NOTIFICATION_ICON_NAME=${toString notification.iconName}
    NOTIFICATION_URGENCY=${notification.urgency}
    NOTIFICATION_TITLE='${notification.title}'

    PATH=${lib.makeBinPath (with pkgs; [coreutils su evtest libnotify])}
    ${builtins.readFile ./disable_kb.sh}
  '';
in {
  security.sudo.extraRules = [
    {
      users = ["jacob"];
      commands = [
        {
          command = script.outPath;
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
