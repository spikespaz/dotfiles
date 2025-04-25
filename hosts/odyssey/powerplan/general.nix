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
  # TODO: Make a pull request for `extraConfig` to allow to be arbitrary attributes.
  # This would make it easier for me to stomach using the module options,
  # which exist for no purpose other than (duplicating) documentation.
  # I don't like maintaining two different attribute sets (or one and a string)
  # just because the NixOS module is not comprehensive.
  services.logind.extraConfig = lib.generators.toKeyValue { } {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    # IdleAction = "suspend-then-hibernate";
    # IdleActionSec = minutes 5;
  };

  # systemd.sleep.extraConfig = lib.generators.toKeyValue { } { # #
  #   HibernateDelaySec = hours 1 + minutes 30;
  # };

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 7;
    percentageAction = 5;
    criticalPowerAction = "HybridSleep";
  };
}
