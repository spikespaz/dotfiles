{ lib, pkgs, hmModules, ... }: {
  imports = [ hmModules.hyprland ];

  home.packages = [
    # Screen Capture
    pkgs.prtsc

    # xwayland perm for pxexec
    pkgs.xorg.xhost
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
    extraConfig = (
      builtins.replaceStrings [
        "%FUNCTIONS%"
      ] [
        (lib.getExe pkgs.keyboard-functions)
      ]
      (lib.concatStringsSep "\n\n" [
        # polkit agent, raises to root access with gui
        "exec-once=${lib.getExe pkgs.lxqt.lxqt-policykit}"
        # allow apps with risen perms after agent to connect to local xwayland
        "exec-once=${lib.getExe pkgs.xorg.xhost} +local:"
        # hyprland config, split up
        (builtins.readFile ./hyprland.conf)
        (builtins.readFile ./displays.conf)
        (builtins.readFile ./keybinds.conf)
        (builtins.readFile ./windowrules.conf)
      ])
    );
  };
}
