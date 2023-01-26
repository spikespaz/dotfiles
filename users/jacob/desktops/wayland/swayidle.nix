{
  config,
  flake,
  lib,
  pkgs,
  hmModules,
  ...
}: {
  imports = [
    flake.modules.swayidle
    hmModules.idlehack
  ];

  # enable the idlehack deamon, it watches for inhibits
  # on dbus and sends them to swayidle/anything listening
  services.idlehack.enable = true;

  # this is the idle daemon by the sway developers
  # it reacts to events (such as timeouts) and runs commands
  # <https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd>
  services.swayidle.alt = let
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    swaylock = "${lib.getExe config.programs.swaylock.package}";
  in {
    enable = true;
    systemdTarget = "hyprland-session.target";

    extraArgs = ["-w"];
    idleHint = 2 * 60;

    events = {
      beforeSleep = ''
        ${swaylock} -f
      '';
      lock = ''
        ${swaylock} -f --grace-no-mouse --grace 5
      '';
    };

    timeouts = {
      autoLock = {
        timeout = 2 * 60;
        script = ''
          ${swaylock} -f --grace 30
        '';
      };
      screenOff = {
        timeout = 5 * 60;
        script = ''
          ${hyprctl} dispatch dpms off
        '';
        resumeScript = ''
          ${hyprctl} dispatch dpms on
        '';
      };
    };
  };
}
