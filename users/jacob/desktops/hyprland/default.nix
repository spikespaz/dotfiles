{ lib, pkgs, inputs, dotpkgs, ... }: {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = [
    # Screen Capture
    dotpkgs.pkgs.prtsc
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
}