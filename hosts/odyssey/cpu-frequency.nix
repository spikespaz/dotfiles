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
    "amd_pstate=active"
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
    KERNEL=="cpu[0-9]|cpu1[0-5]", SUBSYSTEM=="cpu", ATTR{cpufreq/energy_performance_preference}="balance_power"
  '';

  # Now TLP can be used to control this automatically while
  # the system is running. The values set above should be mostly fine,
  # but AC/battery profiles are further constrained below.
  #
  # The driver mode is `guided` so that we can control the frequencies.
  services.tlp.enable = false;
  # Documentation:
  # <https://linrunner.de/tlp/settings>
  services.tlp.settings = let
    MHz = x: x * 1000;

    # These values can be discovered by register files in *sysfs*.
    max_freq = MHz 5132;
    lowest_nonlinear_freq = MHz 1099;

    # Fraction of the frequency range where power consumption is high.
    freq_deficit_bat = 0.2; # approximately 3.2 GHz
  in {
    TLP_ENABLE = 1;
    # TLP_WARN_LEVEL = 3;
    TLP_DEFAULT_MODE = "BAT";

    ## Processor

    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;

    CPU_DRIVER_OPMODE_ON_AC = "guided";
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";

    CPU_SCALING_MIN_FREQ_ON_AC = 0;
    CPU_SCALING_MAX_FREQ_ON_AC = max_freq;

    CPU_DRIVER_OPMODE_ON_BAT = "guided";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

    CPU_SCALING_MIN_FREQ_ON_BAT = 0;
    CPU_SCALING_MAX_FREQ_ON_BAT = max_freq - (builtins.floor
      ((max_freq - lowest_nonlinear_freq) * freq_deficit_bat));
  };
}
