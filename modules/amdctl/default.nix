{ lib, pkgs, config, ... }:
let
  cfg = config.services.undervolt.amdctl;
  inherit (lib) types;

  amdctl = pkgs.stdenv.mkDerivation rec {
    name = "amdctl";
    version = "0.11";
    nativeBuildInputs = [ pkgs.gnumake ];
    installPhase = ''
      runHook preInstall
      make
      install -Dm555 ./amdctl $out/bin/amdctl
      runHook postInstall
    '';
    src = pkgs.fetchFromGitHub {
      owner = "kevinlekiller";
      repo = "amdctl";
      rev = "v${version}";
      sha256 = "sha256-2wBk/9aAD7ARMGbcVxk+CzEvUf8U4RS4ZwTCj8cHNNo=";
    };
  };
in {
  options = {
    services.undervolt.amdctl = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Whether to enable the systemd unit for starting `amdctl`
        on requisite events to maintain a constant undervolt during
        different p-states during normal machine operation.

        The service will fail with code 33 if you have provided invalid
        offset values (recommend multiples of 100).
      '');

      package = lib.mkOption {
        type = types.package;
        default = amdctl;
        description = lib.mdDoc ''
          The package to use for the `amdctl` binary.
        '';
      };

      mode = lib.mkOption {
        type = types.enum [ "inc" "dec" "set" ];
        default = "dec";
        description = lib.mdDoc ''
          By default, {option}`pstateValues` are subtracted from whatever is
          current for each core when the service is executed.
          This is `dec` mode.

          Alternatively, use `set` to apply the {option}`pstateValues`
          to each core's pstates directly, not subtracting or adding.

          While the module is technically for undervolting,
          if you change {option}`mode` to `inc` you can add
          each of {option}`pstateValues` instead of subtracting
          (overvolt instead of undervolt).
        '';
      };

      pstateVoltages = lib.mkOption {
        type = types.nullOr (types.listOf types.ints.unsigned);
        default = null;
        description = lib.mdDoc ''
          > **WARNING:**
          > For now this module assumes all cores
          > have the same pstates and default voltages.
          > The script does set each core and pstate voltage independently,
          > so module options can easily be changed in the future
          > if necessary (for BIG.little CPUs for example).

          A list of offset values in mV to apply to the pstate
          at the corresponding index.

          For example, `[150 100 100]` would apply to a system with
          three pstates:

          ```
          p0 = 1218mv - 150mV = 1068mV
          p1 = 950mV  - 100mV = 850mV
          p2 = 912mV  - 100mV = 812mV
          ```
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # <https://github.com/kevinlekiller/amdctl/>
    environment.systemPackages = [ cfg.package ];

    boot.kernelModules = [ "msr" ];
    boot.kernelParams = [ "msr.allow_writes=on" ];

    systemd.services.undervolt-amdctl =
      let targets = [ "multi-user.target" "post-resume.target" ];
      in {
        serviceConfig.Type = "oneshot";
        path = [ cfg.package ];
        description = "control undervolt with amdctl";
        documentation = [ "https://github.com/kevinlekiller/amdctl" ];
        after = targets;
        wantedBy = targets;
        script = lib.escapeShellArgs
          ([ ./apply-pstate-voltages.sh cfg.mode ] ++ cfg.pstateVoltages);
      };

  };
}
