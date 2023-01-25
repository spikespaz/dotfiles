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
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    swaylock = "${lib.getExe config.programs.swaylock.package}";

    eventNames = {
      beforeSleep = "before-sleep";
      afterResume = "after-resume";
    };

    mkEventsList = lib.mapAttrsToList (name: script: {
      event =
        if eventNames ? ${name}
        then eventNames.${name}
        else name;
      command = (pkgs.writeShellScript "swayidle-${name}" script).outPath;
    });

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

    events = mkEventsList {
      beforeSleep = ''
        ${swaylock} -f
      '';
      lock = ''
        ${swaylock} -f --grace-no-mouse --grace 5
      '';
    };

    timeouts = mkTimeoutsList {
      autoLock = {
        timeout = 2 * 60;
        script = ''
          ${swaylock} -f --grace 30
        '';
      };
      screenOff = {
        timeout = 5 * 60;
        script = ''
          ${hyprctl} dpms on
        '';
        resumeScript = ''
          ${hyprctl} dpms off
        '';
      };
    };

    systemdTarget = "hyprland-session.target";
  };
}
