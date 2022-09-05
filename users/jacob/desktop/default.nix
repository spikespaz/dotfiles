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

  # application launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

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
    source = ./scripts/prtsc.pl;
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
    auto_lock.timeout = 2 * 60;
    auto_lock.grace = 30;
    forced_lock.grace = 5;
  in ''
    timeout ${toString auto_lock.timeout} '${swaylock} -f --grace ${toString auto_lock.grace}'
    before-sleep '${swaylock} -f'
    lock '${swaylock} -f --grace ${toString forced_lock.grace} --grace-no-mouse'
  '';

  # enable the idlehack deamon, it watches for inhibits
  # on dbus and sends them to swayidle/anything listening
  services.idlehack.enable = true;

  # service that auto-mounts storage devices with udisks2
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    # <https://github.com/coldfix/udiskie/blob/master/doc/udiskie.8.txt#configuration>
    # settings = {}
  };

  # should already be enabled at system level
  # fontconfig required to make user-fonts by name
  # todo: figure out how to make ~/.local/share/fonts
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    # some nixpkgs modules have wrapers
    # that force electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # make qt apps expect wayland
    QT_QPA_PLATFORM = "wayland";
    # set backend for sdl
    SDL_VIDEODRIVER = "wayland";
    # fix modals from being attached on tiling wms
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
