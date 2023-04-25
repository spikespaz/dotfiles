{ config, pkgs, lib, ... }:
let
  execs = {
    SLIGHT = lib.getExe pkgs.slight;
    OSD_FUNCTIONS = lib.getExe config.utilities.osd-functions.package;
    DISABLE_INPUT_DEVICES = "disable-input-devices-notify";
    PIN_WINDOW_SCRIPT = "${pkgs.writeShellScript "pin-window"
      (let hyprctl = "${pkgs.hyprland}/bin/hyprctl";
      in ''
        if ${hyprctl} activewindow | grep 'floating: 0'; then
        	${hyprctl} dispatch togglefloating active;
        fi

        ${hyprctl} dispatch pin active
      '')}";
  };
in {
  # prepend the config with more exec lines,
  # for starting swayidle
  wayland.windowManager.hyprland.configLines = lib.mkOrder 800
    (builtins.replaceStrings (builtins.attrNames execs)
      (builtins.attrValues execs) (builtins.readFile ./keybinds.conf));
}
