{ self, config, lib, pkgs, ... }:
let
  # <https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-power>
  battery = "/sys/class/power_supply/BAT0";

  idleHint = minutes 2;

  screenDimTimeoutBAT = minutes 1 + seconds 30;
  autoLockTimeoutBAT = minutes 2;
  screenOffTimeoutBAT = minutes 7;

  screenDimTimeoutAC = minutes 4 + seconds 30;
  autoLockTimeoutAC = minutes 5;
  screenOffTimeoutAC = hours 1;

  lockEventGrace = seconds 5;
  autoLockGrace = seconds 15;

  screenDimTargetBAT = 15; # percent
  screenDimTargetAC = 15; # percent
  screenDimEnterDuration = "2s";
  screenDimLeaveDuration = "500ms";

  hours = x: x * 60 * 60;
  minutes = x: x * 60;
  seconds = x: x;
in {
  imports =
    [ self.homeManagerModules.swayidle self.homeManagerModules.idlehack ];

  # enable the idlehack deamon, it watches for inhibits
  # on dbus and sends them to swayidle/anything listening
  services.idlehack.enable = true;

  # this is the idle daemon by the sway developers
  # it reacts to events (such as timeouts) and runs commands
  # <https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd>
  services.swayidle.alt = let
    grep = lib.getExe pkgs.gnugrep;
    slight = lib.getExe pkgs.slight;
    hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
    swaylock = lib.getExe config.programs.swaylock.package;

    batStatus = states:
      "${grep} -q -x -F ${
        lib.concatMapStrings (s: " -e '${s}'") states
      } ${battery}/status";
    pluggedInAC = batStatus [ "Charging" "Not charging" ];

    screenDimEnter = { target, duration, lockName }: ''
      brightness="$(${slight} get -p)"
      brightness="''${brightness/\%/}"
      if [[ "$brightness" -gt ${toString target} ]]; then
        printf '%s' "$brightness" > /tmp/${lockName}
        ${slight} set -D ${toString target} -t ${duration} &
        printf '%s' "$!" > /tmp/${lockName}.pid
      fi
    '';
    screenDimLeave = { duration, lockName }: ''
      brightness="$(cat /tmp/${lockName})"
      kill "$(cat /tmp/${lockName}.pid)" || true
      ${slight} set -I "$brightness%" -t ${screenDimLeaveDuration}
      rm -f /tmp/${lockName}{,.pid}
    '';
  in {
    enable = true;
    systemdTarget = "hyprland-session.target";

    inherit idleHint;

    events = {
      beforeSleep = ''
        ${swaylock} -f
      '';
      afterResume = ''
        ${hyprctl} dispatch dpms on
      '';
      lock = ''
        ${swaylock} -f --grace-no-mouse --grace ${toString lockEventGrace}
      '';
    };

    timeouts = {
      screenDimBAT = let lockName = ".screen_dim_brightness_bat";
      in {
        timeout = screenDimTimeoutBAT;
        script = ''
          set -eu
          if ! ${pluggedInAC}; then
            ${
              screenDimEnter {
                target = screenDimTargetBAT;
                duration = screenDimEnterDuration;
                inherit lockName;
              }
            }
          fi
        '';
        resumeScript = ''
          set -eu
          ${screenDimLeave {
            duration = screenDimLeaveDuration;
            inherit lockName;
          }}
        '';
      };

      screenDimAC = let lockName = ".screen_dim_brightness_ac";
      in {
        timeout = screenDimTimeoutAC;
        script = ''
          set -eu
          if ${pluggedInAC}; then
            ${
              screenDimEnter {
                target = screenDimTargetAC;
                duration = screenDimEnterDuration;
                inherit lockName;
              }
            }
          fi
        '';
        resumeScript = ''
          set -eu
          ${screenDimLeave {
            duration = screenDimLeaveDuration;
            inherit lockName;
          }}
        '';
      };

      autoLockBAT = {
        timeout = autoLockTimeoutBAT;
        script = ''
          if ! ${pluggedInAC}; then
            ${swaylock} -f --grace ${toString autoLockGrace}
          fi
        '';
      };

      autoLockAC = {
        timeout = autoLockTimeoutAC;
        script = ''
          if ${pluggedInAC}; then
            ${swaylock} -f --grace ${toString autoLockGrace}
          fi
        '';
      };

      screenOffBAT = let lockName = ".timeout_screen_off_bat";
      in {
        timeout = screenOffTimeoutBAT;
        script = ''
          set -eu
          if ! ${pluggedInAC}; then
            ${hyprctl} dispatch dpms off
            touch /tmp/${lockName}
          fi
        '';
        resumeScript = ''
          set -eu
          if [ -f /tmp/${lockName} ]; then
            ${hyprctl} dispatch dpms on
            rm /tmp/${lockName}
          fi
        '';
      };

      screenOffAC = let lockName = ".timeout_screen_off_ac";
      in {
        timeout = screenOffTimeoutAC;
        script = ''
          set -eu
          if ${pluggedInAC}; then
            ${hyprctl} dispatch dpms off
            touch /tmp/${lockName}
          fi
        '';
        resumeScript = ''
          set -eu
          if [ -f /tmp/${lockName} ]; then
            ${hyprctl} dispatch dpms on
            rm /tmp/${lockName}
          fi
        '';
      };
    };
  };
}
