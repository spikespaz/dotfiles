{
  self,
  config,
  lib,
  pkgs,
  hmModules,
  ...
}: {
  imports = [
    self.homeManagerModules.swayidle
    self.homeManagerModules.idlehack
  ];

  # enable the idlehack deamon, it watches for inhibits
  # on dbus and sends them to swayidle/anything listening
  services.idlehack.enable = true;

  # this is the idle daemon by the sway developers
  # it reacts to events (such as timeouts) and runs commands
  # <https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd>
  services.swayidle.alt = let
    grep = lib.getExe pkgs.gnugrep;
    slight = lib.getExe pkgs.slight;
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    swaylock = lib.getExe config.programs.swaylock.package;

    # macro to check if sfsTsBat state matches any states
    # <https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-power>
    sysFsBat = "/sys/class/power_supply/BAT0";
    batStatus = states: "${grep} -q -x -F ${
      lib.concatMapStrings (s: " -e '${s}'") states
    } ${sysFsBat}/status";
  in {
    enable = true;
    systemdTarget = "hyprland-session.target";

    idleHint = 2 * 60;

    events = {
      beforeSleep = ''
        ${swaylock} -f
        ${hyprctl} dispatch dpms off
      '';
      afterResume = ''
        ${hyprctl} dispatch dpms on
      '';
      lock = ''
        ${swaylock} -f --grace-no-mouse --grace 5
      '';
    };

    timeouts = {
      dimScreen = let
        dimTarget = 15;
        dimDuration = "2s";
        undimDuration = "500ms";
      in {
        timeout = 60;
        script = ''
          set -eu
          brightness="$(${slight} get -p)"
          brightness="''${brightness/\%/}"
          if [[ "$brightness" -gt ${toString dimTarget} ]]; then
            printf '%s' "$brightness" > /tmp/.slight_saved_brightness
            ${slight} set -D ${toString dimTarget}% -t ${dimDuration} &
            printf '%s' "$!" > /tmp/.slight_saved_brightness.pid
          fi
        '';
        resumeScript = ''
          set -eu
          brightness="$(cat /tmp/.slight_saved_brightness)"
          kill "$(cat /tmp/.slight_saved_brightness.pid)" || true
          ${slight} set -I "$brightness%" -t ${undimDuration}
          rm -f /tmp/.slight_saved_brightness{,.pid}
        '';
      };

      autoLock = {
        timeout = 2 * 60;
        script = ''
          ${swaylock} -f --grace 30
        '';
      };

      screenOff = {
        timeout = 5 * 60;
        script = ''
          set -eu
          if ! ${batStatus ["Charging" "Not charging"]}; then
            ${hyprctl} dispatch dpms off
            touch /tmp/.timeout_screen_off
          fi
        '';
        resumeScript = ''
          set -eu
          if [ -f /tmp/.timeout_screen_off ]; then
            ${hyprctl} dispatch dpms on
            rm /tmp/.timeout_screen_off
          fi
        '';
      };
        '';
        resumeScript = ''
          ${hyprctl} dispatch dpms on
        '';
      };
    };
  };
}
