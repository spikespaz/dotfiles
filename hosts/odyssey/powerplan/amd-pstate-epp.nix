# Based on Phoronix' results:
# <https://www.phoronix.com/review/amd-pstate-epp-ryzen-mobile>
#
# Required reading:
# <https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html>
# <https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html#amd-pstate-driver-operation-modes>
{ lib, config, ... }: {
  environment.systemPackages = [
    # *cpupower* could be in `packages.nix`, but it's a common diagnostic
    # tool that should probably come along with the config that follows.
    # <https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html#cpupower-tool-support-for-amd-pstate>
    config.boot.kernelPackages.cpupower
  ];

  boot.kernelParams = [ "amd_pstate=active" ];

  services.udev.extraRules = let
    num_cpus = 16;
    scaling_governor = "powersave";
    energy_performance_preference = "balance_power";
  in lib.concatLines (lib.genList (cpu: ''
    KERNEL=="cpu${
      toString cpu
    }", SUBSYSTEM=="cpu", ATTR{cpufreq/scaling_governor}="${scaling_governor}"
    KERNEL=="cpu${
      toString cpu
    }", SUBSYSTEM=="cpu", ATTR{cpufreq/energy_performance_preference}="${energy_performance_preference}"
  '') num_cpus);

  services.tlp.enable = true;
  # Documentation: <https://linrunner.de/tlp/settings>
  services.tlp.settings = let
    MHz = x: x * 1000;

    # These values can be discovered by register files in *sysfs*.
    # Ensure `boost` is `1` before checking.
    # `cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`
    max_freq = MHz 5132;
    # `cat /sys/devices/system/cpu/cpu0/cpufreq/amd_pstate_lowest_nonlinear_freq`
    lowest_nonlinear_freq = MHz 1099;

    # Fraction of the frequency range where power consumption is high.
    freq_deficit_bat = 0.2; # approximately 3.2 GHz
  in {
    TLP_ENABLE = true;
    # TLP_WARN_LEVEL = 3;
    TLP_DEFAULT_MODE = "BAT";

    # Processor: <https://linrunner.de/tlp/settings/processor.html>

    CPU_BOOST_ON_AC = true;
    # Disabling boost on battery power will reduce the `cpuinfo_max_freq` according
    # to driver code. If this new maximum is less than `CPU_SCALING_MAX_FREQ_ON_BAT`,
    # the latter will not apply.
    # Keep this enabled to allow the CPU to boost on battery, but clamp the frequency
    # according to `freq_deficit_bat` above.
    CPU_BOOST_ON_BAT = true;

    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";

    CPU_SCALING_MIN_FREQ_ON_AC = lowest_nonlinear_freq;
    CPU_SCALING_MAX_FREQ_ON_AC = max_freq;

    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

    CPU_SCALING_MIN_FREQ_ON_BAT = 0;
    CPU_SCALING_MAX_FREQ_ON_BAT = max_freq - (builtins.floor
      ((max_freq - lowest_nonlinear_freq) * freq_deficit_bat));
  };
}
