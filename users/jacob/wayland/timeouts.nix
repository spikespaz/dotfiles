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
  sleepTimeoutBAT = minutes 15;

  # Options for timeouts on AC
  screenDimTimeoutAC = minutes 4 + seconds 30;
  autoLockTimeoutAC = minutes 5;
  screenOffTimeoutAC = minutes 15;
  kbdLightOffTimeoutAC = minutes 2;
  sleepTimeoutAC = null; # never

  # Screen dimming settings
  screenDimTargetBAT = 15; # percent
  screenDimTargetAC = 15; # percent
  screenDimEnterDuration = "2s";
  screenDimLeaveDuration = "500ms";

  # Lock screen settings
  lockEventGrace = seconds 5;
  autoLockGrace = seconds 15;

  # Keyboard backlight settings
  kbdLightOffValue = 0;

  # Sleep settings
  # sleepVerbBAT = "suspend-then-hibernate";
  sleepVerbBAT = "hybrid-sleep";
  sleepVerbAC = "hybrid-sleep";

  # Utility functions
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
  services.swayidle = let
    slight = lib.getExe pkgs.slight;
    hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
    swaylock = lib.getExe config.programs.swaylock.package;

    lockFileDir = "/var/run/user/$(id -u)/swayidle";

    screenDimEnter = { target, duration, lockName }: ''
      set -eu
      brightness="$(${slight} get -p)"
      brightness="''${brightness/\%/}"
      if [[ "$brightness" -gt ${toString target} ]]; then
        mkdir -p "${lockFileDir}"
        printf '%s' "$brightness" > "${lockFileDir}/${lockName}"
        ${slight} set -D ${toString target} -t ${duration} &
        printf '%s' "$!" > "${lockFileDir}/${lockName}.pid"
      fi
      set +eu
    '';
    screenDimLeave = { duration, lockName }: ''
      set -eu
      brightness="$(cat "${lockFileDir}/${lockName}")"
      kill "$(cat "${lockFileDir}/${lockName}.pid")" || true
      ${slight} set -I "$brightness%" -t ${duration}
      rm -f "${lockFileDir}/${lockName}"{,.pid}
      set +eu
    '';

    # no real PID lock file (just saved brightness) because
    # this is basically instant with no duration.
    kbdLightOffEnter = { device, target, lockName }: ''
      set -eu
      brightness="$(${slight} -D ${kbdLightDevice} get)"
      if [[ "$brightness" -gt ${toString target} ]]; then
        mkdir -p "${lockFileDir}"
        printf '%s' "$brightness" > "${lockFileDir}/${lockName}"
        ${slight} -D ${device} set -D ${toString target}
      fi
      set +eu
    '';
    kbdLightOffLeave = { device, lockName }: ''
      set -eu
      brightness="$(cat "${lockFileDir}/${lockName}")"
      ${slight} -D ${device} set -I "$brightness"
      rm -f "${lockFileDir}/${lockName}"{,.pid}
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

    batteryTimeouts = let
      lockName.screenDim = "screenDim-battery_brightness";
      lockName.kbdLightOff = "kbdLightOff-battery_brightness";
    in {
      screenDim = lib.mkIf (screenDimTimeoutBAT != null) {
        timeout = screenDimTimeoutBAT;
        script = screenDimEnter {
          target = screenDimTargetBAT;
          duration = screenDimEnterDuration;
          lockName = lockName.screenDim;
        };
        resumeScript = screenDimLeave {
          duration = screenDimLeaveDuration;
          lockName = lockName.screenDim;
        };
      };

      autoLock = lib.mkIf (autoLockTimeoutBAT != null) {
        timeout = autoLockTimeoutBAT;
        script = ''
          ${swaylock} -f --grace ${toString autoLockGrace}
        '';
      };

      screenOff = lib.mkIf (screenOffTimeoutBAT != null) {
        timeout = screenOffTimeoutBAT;
        script = ''
          ${hyprctl} dispatch dpms off
        '';
        resumeScript = ''
          ${hyprctl} dispatch dpms on
        '';
      };

      kbdLightOff = lib.mkIf (kbdLightOffTimeoutBAT != null) {
        timeout = kbdLightOffTimeoutBAT;
        script = kbdLightOffEnter {
          device = kbdLightDevice;
          target = kbdLightOffValue;
          lockName = lockName.kbdLightOff;
        };
        resumeScript = kbdLightOffLeave {
          device = kbdLightDevice;
          lockName = lockName.kbdLightOff;
        };
      };

      sleep = lib.mkIf (sleepTimeoutBAT != null) {
        timeout = sleepTimeoutBAT;
        script = ''
          systemctl ${sleepVerbBAT}
        '';
      };
    };

    pluggedInTimeouts = let
      lockName.screenDim = "screenDim-pluggedIn_brightness";
      lockName.kbdLightOff = "kbdLightOff-pluggedIn_brightness";
    in {
      screenDim = lib.mkIf (screenDimTimeoutAC != null) {
        timeout = screenDimTimeoutAC;
        script = screenDimEnter {
          target = screenDimTargetAC;
          duration = screenDimEnterDuration;
          lockName = lockName.screenDim;
        };
        resumeScript = screenDimLeave {
          duration = screenDimLeaveDuration;
          lockName = lockName.screenDim;
        };
      };

      autoLock = lib.mkIf (autoLockTimeoutAC != null) {
        timeout = autoLockTimeoutAC;
        script = ''
          ${swaylock} -f --grace ${toString autoLockGrace}
        '';
      };

      screenOff = lib.mkIf (screenOffTimeoutAC != null) {
        timeout = screenOffTimeoutAC;
        script = ''
          ${hyprctl} dispatch dpms off
        '';
        resumeScript = ''
          ${hyprctl} dispatch dpms on
        '';
      };

      kbdLightOff = lib.mkIf (kbdLightOffTimeoutAC != null) {
        timeout = kbdLightOffTimeoutAC;
        script = kbdLightOffEnter {
          device = kbdLightDevice;
          target = kbdLightOffValue;
          lockName = lockName.kbdLightOff;
        };
        resumeScript = kbdLightOffLeave {
          device = kbdLightDevice;
          lockName = lockName.kbdLightOff;
        };
      };

      sleep = lib.mkIf (sleepTimeoutAC != null) {
        timeout = sleepTimeoutAC;
        script = ''
          systemctl ${sleepVerbAC}
        '';
      };
    };
  };
}
