# Required Reading:
# - <https://www.kernel.org/doc/Documentation/power/states.txt>
# - `man sleep.conf.d`
# - `man logind.conf`
{ lib, ... }:
let
  # hours = h: minutes 60 * h;
  # minutes = m: seconds 60 * m;
  # seconds = s: s;
in {
  services.logind = {
    lidSwitch = "suspend";
    killUserProcesses = true;
    extraConfig = ''
      HandlePowerKey=suspend
      HandlePowerKeyLongPress=poweroff
      HandleLidSwitchExternalPower=suspend
    '';
    # IdleAction=suspend-then-hibernate
    # IdleActionSec=${toString (minutes 5)}
  };

  # systemd.sleep.extraConfig = ''
  #   HibernateDelaySec=${toString (hours 1 + minutes 30)}
  # '';

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 7;
    percentageAction = 5;
    criticalPowerAction = "HybridSleep";
  };

  services.thinkfan = {
    enable = true;

    # <https://github.com/m4tx/thinkpad-p14s-g4-linux/blob/dc24c03f00548d1f5f723c178cd49c639b5c35ec/thinkfan.conf>
    settings = {
      sensors = [
        # GPU
        {
          hwmon = "/sys/class/hwmon";
          name = "amdgpu";
          indices = [ 1 ];
        }
        # CPU
        {
          hwmon = "/sys/class/hwmon";
          name = "k10temp";
          indices = [ 1 ];
        }
        # Chassis
        {
          hwmon = "/sys/class/hwmon";
          name = "thinkpad";
          indices = [ 1 3 6 7 ];
          max_errors = 10;
        }
        # SSD
        {
          hwmon = "/sys/class/hwmon";
          name = "nvme";
          indices = [ 1 2 3 ];
          correction = [ (-5) 0 0 ];
        }
        # Motherboard
        {
          hwmon = "/sys/class/hwmon";
          name = "acpitz";
          indices = [ 1 ];
        }
      ];

      fans = [{ tpacpi = "/proc/acpi/ibm/fan"; }];

      levels = [
        [ 0 0 60 ]
        [ 1 58 63 ]
        [ 2 61 66 ]
        [ 3 64 69 ]
        [ 4 67 72 ]
        [ 5 70 75 ]
        [ 6 73 78 ]
        [ 7 76 81 ]
        [ "level full-speed" 79 32767 ]
      ];
    };
  };

  systemd.services.thinkfan = {
    serviceConfig = lib.mapAttrs (_: lib.mkForce) {
      # <https://github.com/NixOS/nixpkgs/pull/400282>
      # <https://github.com/vmatare/thinkfan/pull/198>
      CPUSchedulingPolicy = "fifo";
      CPUSchedulingPriority = 20; # high, but not the highest
      RestartSec = "2s"; # slow restart is a problem if not exit cleanly
      OOMScoreAdjust = -1000; # never kill this unit if out of memory
      MemorySwapMax = 0; # never swap
    };
  };
}
