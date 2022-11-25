{
  lib,
  pkgs,
  hmModules,
  ...
}: {
  imports = [
    hmModules.hyprland
    ./config.nix
    ./windowrules.nix
  ];

  home.packages = [
    # Screen Capture
    pkgs.prtsc

    # xwayland perm for pkexec
    pkgs.xorg.xhost
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;

    xwayland.enable = true;
    xwayland.hidpi = false;

    extraInitConfig = ''
      # polkit agent, raises to root access with gui
      exec-once = ${lib.getExe pkgs.lxqt.lxqt-policykit}
      # allow apps with risen perms after agent to connect to local xwayland
      exec-once = ${lib.getExe pkgs.xorg.xhost} +local:
    '';

    # prepend the config with more exec lines,
    # for starting swayidle
    extraConfig = (
      builtins.replaceStrings [
        "%FUNCTIONS%"
      ] [
        (lib.getExe (pkgs.keyboard-functions.override {
          scriptOptions = {
            # to get it to the top of the list
            urgency = "critical";
            outputMaximum = 1.25;
            colors.normalHighlight = "#458588e6";
            colors.warningHighlight = "#cc241de6";
          };
        }))
      ]
      (lib.concatStringsSep "\n\n" [
        ''
          blurls = rofi
          blurls = notifications
        ''
        # hyprland config, split up
        (builtins.readFile ./displays.conf)
        (builtins.readFile ./keybinds.conf)
      ])
    );
  };
}
