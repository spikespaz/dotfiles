{ config, pkgs, lib, ... }: {
  imports = [
    ./theming.nix
  ];

  home.packages = [
    # Idle Event Daemon
    pkgs.swayidle

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

    # prepend the config with more exec lines,
    # for starting swayidle
    extraConfig = ''
      exec-once=${lib.getExe pkgs.swayidle}
    '' + builtins.readFile ./configs/hyprland.conf;
  };

  # create a service for swaybg that sets a wallpaper randomly
  systemd.user.services.random-wallpaper = let
    # 25% chance to change the wallpaper on each hour
    interval = 1 * 60 * 60;
    chance = 25;
    img_dir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  in{
    Unit = {
      Description = "wayland random wallpaper utility";
      PartOf = "graphical-session.target";
    };
    Service = {
      Type = "notify";
      NotifyAccess = "all";  # because of a bug?
      Environment = ''
        PATH=${with pkgs; lib.makeBinPath [
          systemd coreutils procps findutils swaybg
        ]}
      '';
      ExecStart = ''
        ${./scripts/wallpaper.sh} \
          ${toString interval} ${toString chance} '${img_dir}'
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # screenshot utility
  # this is an exec bind in hyprland config
  xdg.configFile."hypr/prtsc.pl" = {
    source = ../scripts/prtsc.pl;
    executable = true;
  };

  # configure swaylock theme
  programs.swaylock.settings = import ./configs/swaylock.nix;

  # write the config to the expected location and
  # execute from hyprland because the systemd service doesn't work
  xdg.configFile."swayidle/config".text = let
    # the swayidle path in the nixpkg is wrong
    # <https://github.com/NixOS/nixpkgs/pull/189452>
    # swaylock = lib.getExe pkgs.swaylock-effects;
    swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  in ''
    timeout ${toString (2 * 60)} '${swaylock} -f --grace 30'
    before-sleep '${swaylock} -f'
    lock '${swaylock} -f --grace 5 --grace-no-mouse'
  '';

  # # runs commands when events from logind or inactive timeout
  # services.swayidle = {
  #   enable = true;
  #   events = [
  #     { event = "before-sleep"; command = "swaylock -f"; }
  #     { event = "lock"; command = "swaylock -f"; }
  #   ];
  #   timeouts = [
  #     # lock after 1 minute with a grace of 30 seconds
  #     {
  #       timeout = 2 * 60;
  #       command = "swaylock -f --grace 30";
  #     }
  #     # for testing
  #     { timeout = 5; command = "swaylock -f --grace 10"; }
  #   ];
  # };

  # # make some modifications to the swayidle service
  # # WantedBy is sway-session.target by default
  # systemd.user.services.swayidle.Install.WantedBy =
  #   lib.mkForce [ "hyprland-session.target" ];
  # systemd.user.services.swayidle.Service.Restart = "on-failure";
  # systemd.user.services.swayidle.Service.RestartSec = 5;

  # service that auto-mounts storage devices with udisks2
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    # <https://github.com/coldfix/udiskie/blob/master/doc/udiskie.8.txt#configuration>
    # settings = {}
  };

  home.sessionVariables = {
    # some nixpkgs modules have wrapers
    # that force electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };
}
