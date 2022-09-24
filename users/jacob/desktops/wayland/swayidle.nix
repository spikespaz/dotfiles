{ lib, pkgs, hmModules, ... }: {
  imports = [ hmModules.idlehack ];

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
  in {
    enable = true;

    events = [
      {
        event = "before-sleep";
        command = "${lib.getExe pkgs.swaylock-effects} -f";
      }
      {
        event = "lock";
        command = lib.concatStringsSep " " [
          (lib.getExe pkgs.swaylock-effects)
          "-f"
          "--grace"
          (toString forcedLock.grace)
          "--grace-no-mouse"
        ];
      }
    ];

    timeouts = [
      {
        timeout = autoLock.timeout;
        command = lib.concatStringsSep " " [
          (lib.getExe pkgs.swaylock-effects)
          "-f"
          "--grace"
          (toString autoLock.grace)
        ];
      }
    ];

    systemdTarget = "hyprland-session.target";
  };
}
