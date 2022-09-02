{ pkgs, lib, ... }: {
  imports = [
    ./theming.nix
  ];

  home.packages = [
    # Lock Screen
    pkgs.swaylock-effects

    # Wallpaper
    pkgs.swaybg

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
    extraConfig = builtins.readFile ./configs/hyprland.conf;
  };

  # create a service for swaybg so that we don't
  # start a new process every time the wallpaper is changed  
  systemd.user.services.swaybg = {
    Unit.Description = "wayland wallpaper utility";
    Service.ExecStart = "${lib.getExe pkgs.swaybg} -c '#121212'";
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # write the script for the wallpaper
  # this is an exec in hyprland config
  xdg.configFile."hypr/wallpaper.sh" = let
    wallpaper = "/home/jacob/OneDrive/Pictures/Wallpapers/RykyArt Patreon/Favorites/antlers.png";
  in {
    text = "swaybg -m fit --image '${wallpaper}'";
    executable= true;
  };

  # screenshot utility
  # this is an exec bind in hyprland config
  xdg.configFile."hypr/prtsc.pl" = {
    source = ../scripts/prtsc.pl;
    executable = true;
  };

  # configure swaylock theme
  programs.swaylock.settings = import ./configs/swaylock.nix;

  # runs commands when events from logind or inactive timeout
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "swaylock -f"; }
      { event = "lock"; command = "swaylock -f"; }
    ];
    timeouts = [
      # lock after 1 minute with a grace of 30 seconds
      {
        timeout = 2 * 60;
        command = "swaylock -f --grace 30";
      }
      # for testing
      { timeout = 5; command = "swaylock -f --grace 10"; }
    ];
  };

  # service that auto-mounts storage devices with udisks2
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    # <https://github.com/coldfix/udiskie/blob/master/doc/udiskie.8.txt#configuration>
    # settings = {}
  };
}
