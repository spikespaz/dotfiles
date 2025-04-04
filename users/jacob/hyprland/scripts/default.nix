{ patchShellScript, hyprland, jq, systemd, grim, wl-clipboard, libnotify, }: # #
{
  pin-window = patchShellScript ./pin-window.sh { # #
    runtimeInputs = [ hyprland jq ];
  };
  toggle-silent-running = patchShellScript ./silent-running.sh {
    runtimeInputs = [ jq systemd hyprland ];
  };
  screenshot-window = patchShellScript ./screenshot.sh {
    runtimeInputs = [ jq grim wl-clipboard libnotify hyprland ];
  };
  toggle-group-or-lock = patchShellScript ./toggle-group-or-lock.sh {
    runtimeInputs = [ jq hyprland ];
  };
}
