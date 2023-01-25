{
  config,
  lib,
  pkgs,
  hmModules,
  ...
}: {
  imports = [hmModules.idlehack];

  # enable the idlehack deamon, it watches for inhibits
  # on dbus and sends them to swayidle/anything listening
  services.idlehack.enable = true;

  # this is the idle daemon by the sway developers
  # it reacts to events (such as timeouts) and runs commands
  # <https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd>
  services.swayidle = let
    autoLock.timeout = 2 * 60;
    autoLock.grace = 30;
    forcedLock.grace = 5;

    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    swaylock = "${lib.getExe config.programs.swaylock.package}";

    mkTimeoutsList = lib.mapAttrsToList (
      name: {
        timeout,
        script,
        resumeScript ? null,
      }: {
        inherit timeout;
        command = (pkgs.writeShellScript "swayidle-${name}" script).outPath;
        resumeCommand =
          if resumeScript == null
          then null
          else (pkgs.writeShellScript "swayidle-${name}-resume" resumeScript).outPath;
      }
    );
  in {
    enable = true;

    events = [
      {
        event = "before-sleep";
        command =
          (pkgs.writeShellScript "swayidle-beforeSleep" ''
            ${swaylock} -f
          '')
          .outPath;
      }
      {
        event = "lock";
        command =
          (pkgs.writeShellScript "swayidle-forcedLock" ''
            ${swaylock} -f --grace ${toString forcedLock.grace} --grace-no-mouse
          '')
          .outPath;
      }
    ];

    timeouts = mkTimeoutsList {
      autoLock = {
        timeout = 2 * 60;
        script = ''
          ${swaylock} -f --grace 30
        '';
      };
    };

    systemdTarget = "hyprland-session.target";
  };
}
