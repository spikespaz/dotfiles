{ callPackage, patchShellScript, patchNuScript, hyprland, jq, systemd, grim
, wl-clipboard, libnotify, coreutils, util-linux, blueman }:

{
  bluetooth = patchShellScript ./bluetooth.sh {
    runtimeInputs = [ coreutils util-linux systemd blueman ];
  };
  pin-window = patchShellScript ./pin-window.sh { # #
    runtimeInputs = [ hyprland jq ];
  };
  toggle-silent-running = patchShellScript ./silent-running.sh {
    runtimeInputs = [ jq systemd hyprland ];
  };
  screenshot-window = patchShellScript ./screenshot.sh {
    runtimeInputs = [ jq grim wl-clipboard libnotify hyprland ];
  };
  switch-keyboard-layout = patchNuScript ./switch-keyboard-layout.nu { # #
    runtimeInputs = [ hyprland ];
  };
  toggle-group-or-lock = patchShellScript ./toggle-group-or-lock.sh {
    runtimeInputs = [ jq hyprland ];
  };
  hypr-alt-tab = callPackage ./hypr-alt-tab { };
}
