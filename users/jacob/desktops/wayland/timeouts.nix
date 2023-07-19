{ self, config, lib, pkgs, ... }:
let
  # <https://docs.kernel.org/leds/leds-class.html>
  kbdLightDevice = "/sys/class/leds/tpacpi::kbd_backlight";

  idleHint = minutes 2;

  # Options for timeouts on battery
  screenDimTimeoutBAT = minutes 1 + seconds 30;
  autoLockTimeoutBAT = minutes 2;
  screenOffTimeoutBAT = minutes 7;
  kbdLightOffTimeoutBAT = seconds 45;

  # Options for timeouts on AC
  screenDimTimeoutAC = minutes 4 + seconds 30;
  autoLockTimeoutAC = minutes 5;
  screenOffTimeoutAC = hours 1;
  kbdLightOffTimeoutAC = minutes 2;

  # Lock screen settings
  lockEventGrace = seconds 5;
  autoLockGrace = seconds 15;

  # Screen dimming settings
  screenDimTargetBAT = 15; # percent
  screenDimTargetAC = 15; # percent
  screenDimEnterDuration = "2s";
  screenDimLeaveDuration = "500ms";

  # Keyboard backlight settings
  kbdLightOffValue = 0;

  hours = x: x * 60 * 60;
  minutes = x: x * 60;
  seconds = x: x;
in {
  imports =
    [ self.homeManagerModules.swayidle self.homeManagerModules.idlehack ];

  # enable the idlehack daemon, it watches for inhibits
  # on dbus and sends them to swayidle/anything listening
  services.idlehack.enable = true;

  # this is the idle daemon by the sway developers
  # it reacts to events (such as timeouts) and runs commands
  # <https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd>
  services.swayidle.alt = let
    slight = lib.getExe pkgs.slight;
    hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
    swaylock = lib.getExe config.programs.swaylock.package;

    screenDimEnter = { target, duration, lockName }: ''
      set -eu
      brightness="$(${slight} get -p)"
      brightness="''${brightness/\%/}"
      if [[ "$brightness" -gt ${toString target} ]]; then
        printf '%s' "$brightness" > /tmp/${lockName}
        ${slight} set -D ${toString target} -t ${duration} &
        printf '%s' "$!" > /tmp/${lockName}.pid
      fi
      set +eu
    '';
    screenDimLeave = { duration, lockName }: ''
      set -eu
      brightness="$(cat /tmp/${lockName})"
      kill "$(cat /tmp/${lockName}.pid)" || true
      ${slight} set -I "$brightness%" -t ${duration}
      rm -f /tmp/${lockName}{,.pid}
      set +eu
    '';

    # no real PID lock file (just saved brightness) because
    # this is basically instant with no duration.
    kbdLightOffEnter = { device, target, lockName }: ''
      set -eu
      brightness="$(${slight} -D ${kbdLightDevice} get)"
      if [[ "$brightness" -gt ${toString target} ]]; then
        printf '%s' "$brightness" > /tmp/${lockName}
        ${slight} -D ${device} set -D ${toString target}
      fi
      set +eu
    '';
    kbdLightOffLeave = { device, lockName }: ''
      set -eu
      brightness="$(cat /tmp/${lockName})"
      ${slight} -D ${device} set -I "$brightness"
      rm -f /tmp/${lockName}{,.pid}
      set +eu
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

    batteryTimeouts = {
      screenDim = let lockName = ".screen_dim_brightness_bat";
      in {
        timeout = screenDimTimeoutBAT;
        script = screenDimEnter {
          target = screenDimTargetBAT;
          duration = screenDimEnterDuration;
          inherit lockName;
        };
        resumeScript = screenDimLeave {
          duration = screenDimLeaveDuration;
          inherit lockName;
        };
      };

      autoLock = {
        timeout = autoLockTimeoutBAT;
        script = ''
          ${swaylock} -f --grace ${toString autoLockGrace}
        '';
      };

      screenOff = {
        timeout = screenOffTimeoutBAT;
        script = ''
          ${hyprctl} dispatch dpms off
        '';
        resumeScript = ''
          ${hyprctl} dispatch dpms on
        '';
      };

      kbdLightOff = let lockName = ".timeout_kbd_light_off_bat";
      in {
        timeout = kbdLightOffTimeoutBAT;
        script = kbdLightOffEnter {
          device = kbdLightDevice;
          target = kbdLightOffValue;
          inherit lockName;
        };
        resumeScript = kbdLightOffLeave {
          device = kbdLightDevice;
          inherit lockName;
        };
      };
    };

    pluggedInTimeouts = {
      screenDim = let lockName = ".screen_dim_brightness_ac";
      in {
        timeout = screenDimTimeoutAC;
        script = screenDimEnter {
          target = screenDimTargetAC;
          duration = screenDimEnterDuration;
          inherit lockName;
        };
        resumeScript = screenDimLeave {
          duration = screenDimLeaveDuration;
          inherit lockName;
        };
      };

      autoLock = {
        timeout = autoLockTimeoutAC;
        script = ''
          ${swaylock} -f --grace ${toString autoLockGrace}
        '';
      };

      screenOff = {
        timeout = screenOffTimeoutAC;
        script = ''
          ${hyprctl} dispatch dpms off
        '';
        resumeScript = ''
          ${hyprctl} dispatch dpms on
        '';
      };

      kbdLightOff = let lockName = ".timeout_kbd_light_off_ac";
      in {
        timeout = kbdLightOffTimeoutAC;
        script = kbdLightOffEnter {
          device = kbdLightDevice;
          target = kbdLightOffValue;
          inherit lockName;
        };
        resumeScript = kbdLightOffLeave {
          device = kbdLightDevice;
          inherit lockName;
        };
      };
    };
  };
}
