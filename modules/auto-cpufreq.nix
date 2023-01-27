{
  config,
  lib,
  ...
}: let
  inherit (lib) types generators;
  cfg = config.services.auto-cpufreq;
in {
  options = {
    services.auto-cpufreq.settings = lib.mkOption {
      type = types.attrs;
      default = {};
      example = lib.literalExpression ''
        {
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
        }
      '';
      description = lib.mdDoc ''
        Settings for *auto-cpufreq*.
        See the readme on GitHub for valid entries:
        <https://github.com/AdnanHodzic/auto-cpufreq#2-auto-cpufreq-config-file>
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.etc."auto-cpufreq.conf".text =
      generators.toINI {} cfg.settings;
  };
}
