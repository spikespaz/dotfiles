# Required Reading:
# - <https://www.kernel.org/doc/Documentation/power/states.txt>
# - `man sleep.conf.d`
# - `man logind.conf`
{
  lib,
  modules,
  ...
}: let
  idle_after = 5 * 60;
  hibernate_delay = 30 * 60;
in {
  imports = [modules.auto-cpufreq];

  services.auto-cpufreq = let
    MHz = x: x * 1000;
  in {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        scaling_min_freq = MHz 1400;
        scaling_max_freq = MHz 1600;
        turbo = "never";
      };
      charger = {
        governor = "performance";
        scaling_min_freq = MHz 1600;
        scaling_max_freq = MHz 1700;
        turbo = "auto";
      };
    };
  };

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    killUserProcesses = true;
    extraConfig = ''
      IdleAction=suspend-then-hibernate
      IdleActionSec=${toString idle_after}
      HandlePowerKey=suspend-then-hibernate
      HandlePowerKeyLongPress=poweroff
      HandleLidSwitchExternalPower=suspend-then-hibernate
    '';
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=${toString hibernate_delay}
  '';

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 7;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  environment.shellAliases = {
    # command for all users to get the current status of the battery
    show-battery = ''
      upower -i /org/freedesktop/UPower/devices/battery_BAT0 \
        | grep -E 'state|charge-cycles|time\ to|percentage' \
        | sed 's/^ *//g'
    '';
    # command for all users to get the path used by their clight daemon
    clight-config = ''
      printf $(systemctl --user cat clight.service | grep ExecStart | sed -E 's/.+--conf-file //')
    '';
  };
}
