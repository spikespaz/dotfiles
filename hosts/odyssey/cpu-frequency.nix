{ config, ... }: {
  # imports = [ self.nixosModules.amdctl ];

  environment.systemPackages = [
    # *cpupower* could be in `packages.nix`, but it's a common diagnostic
    # tool that should probably come along with the config that follows.
    # <https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html#cpupower-tool-support-for-amd-pstate>
    config.boot.kernelPackages.cpupower
  ];

  boot.kernelParams = [
    # Required reading:
    # <https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html>
    # <https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html#amd-pstate-driver-operation-modes>
    #
    # Note that the EPP driver succeeds TLP's scheduler switching
    # and makes it obsolete. Disable that function of TLP.
    "amd_cpufreq=active"
  ];

  # This CPU (R7 8740U) has these energy performance preferences:
  # default, performance, balance_performance, balance_power, power.
  #
  # Based on Phoronix' results:
  # <https://www.phoronix.com/review/amd-pstate-epp-ryzen-mobile>
  #
  # I have decided on scheduler `powersave` and EPP `balance_performance`.
  # I will also consider `powersave` and ` balance_power` once we know more.
  #
  # I assume `balance_performance` means to choose to balance
  # performance over power efficiency,
  # and `balance_power` chooses efficiency over performance.
  services.udev.extraRules = ''
    KERNEL=="cpu[0-9]|cpu1[0-5]", SUBSYSTEM=="cpu", ATTR{cpufreq/scaling_governor}="powersave"
    KERNEL=="cpu[0-9]|cpu1[0-5]", SUBSYSTEM=="cpu", ATTR{cpufreq/energy_performance_preference}="balance_performance"
  '';
}
