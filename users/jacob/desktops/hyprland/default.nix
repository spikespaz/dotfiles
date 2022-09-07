{ lib, pkgs, inputs, ... }: {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = [
    # Screen Capture
    pkgs.grim
    pkgs.slurp
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
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

  # screenshot utility
  # this is an exec bind in hyprland config
  xdg.configFile."hypr/prtsc.pl" = {
    source = ./prtsc.pl;
    executable = true;
  };
}
