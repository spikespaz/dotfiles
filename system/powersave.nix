# Required Reading:
# - <https://www.kernel.org/doc/Documentation/power/states.txt>
# - `man sleep.conf.d`
# - `man logind.conf`
{ lib, modules, ... }: let
  idle_after = 5 * 60;
  hibernate_delay = 30 * 60;
in {
  imports = [ modules.auto-cpufreq ];

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        scaling_min_freq = 1700000;
        scaling_max_freq = 1700000;
        turbo = "auto";
      };
      battery = {
        governor = "powersave";
        scaling_min_freq = 1400000;
        scaling_max_freq = 1600000;
        turbo = "never";
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
