{
  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    extraConfig = builtins.readFile ./hyprland.conf;
  };
}
