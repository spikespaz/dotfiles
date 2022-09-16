{ lib, pkgs, hyprland, ... }: {
  imports = [
    hyprland.hmModules.default
  ];

  home.packages = [
    # Screen Capture
    pkgs.prtsc
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };

    # prepend the config with more exec lines,
    # for starting swayidle
    extraConfig = lib.concatStringsSep "\n\n" [
      "exec-once=${lib.getExe pkgs.swayidle}"
      (builtins.readFile ./hyprland.conf)
      (builtins.readFile ./displays.conf)
      (builtins.readFile ./keybinds.conf)
      (builtins.readFile ./windowrules.conf)
    ];
  };
}
