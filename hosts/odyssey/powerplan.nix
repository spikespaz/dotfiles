# Required Reading:
# - <https://www.kernel.org/doc/Documentation/power/states.txt>
# - `man sleep.conf.d`
# - `man logind.conf`
{ self, config, ... }:
let
  hours = h: minutes 60 * h;
  minutes = m: seconds 60 * m;
  seconds = s: s;
in {
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    killUserProcesses = true;
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      HandlePowerKeyLongPress=poweroff
      HandleLidSwitchExternalPower=suspend-then-hibernate
    '';
    # IdleAction=suspend-then-hibernate
    # IdleActionSec=${toString (minutes 5)}
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=${toString (hours 1 + minutes 30)}
  '';

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 7;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };
}
