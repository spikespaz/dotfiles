{
  config,
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.hyprland = {
    eventListener.enable = true;
    eventListener.systemdService = true;

    eventListener.handler = let
      hyprctl = "${pkgs.hyprland}/bin/hyprctl";
      testRe = against: patterns:
        lib.concatStringsSep " || "
        (map (p: "[[ \"\$${against}\" =~ ^(${p})$ ]]") patterns);
    in {
      monitorAdd = ''
        ${hyprctl} dispatch moveworkspacetomonitor 2 $HL_MONITOR_NAME
        ${hyprctl} dispatch moveworkspacetomonitor 4 $HL_MONITOR_NAME
        ${hyprctl} dispatch moveworkspacetomonitor 6 $HL_MONITOR_NAME
        ${hyprctl} dispatch moveworkspacetomonitor 8 $HL_MONITOR_NAME
        ${hyprctl} dispatch moveworkspacetomonitor 10 $HL_MONITOR_NAME
      '';
    };
  };
}
