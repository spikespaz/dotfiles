# Required Reading:
# - <https://www.kernel.org/doc/Documentation/power/states.txt>
# - `man sleep.conf.d`
# - `man logind.conf`
{ ... }:
  let
    idle_after = 5 * 60;
    hibernate_delay = 30 * 60;
  in
{
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
}
