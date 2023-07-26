{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.services.swayidle;

  typeTimeout = { name, ... }: {
    options = {
      scriptName = lib.mkOption {
        type = types.singleLineStr;
        readOnly = true;
        visible = false;
        default = name;
      };
      timeout = lib.mkOption {
        type = types.ints.positive;
        description = lib.mdDoc ''
          The amount of idle time (in seconds) to wait before
          executing the provided script.
        '';
      };
      script = lib.mkOption {
        type = types.lines;
        description = lib.mdDoc ''
          Lines of shell code to execute after the idle timeout.
        '';
      };
      resumeScript = lib.mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = lib.mdDoc ''
          Lines of shell code to execute when activity is detected again,
          after the main timeout script has executed.
        '';
      };
    };
  };

  typeRootPath = lib.mkOptionType {
    name = "rootPath";
    description = "path starting from root";
    descriptionClass = "noun";
    check = x: builtins.isString x && builtins.substring 0 1 x == "/";
    merge = lib.mergeEqualOption;
  };
in {
  # replaces home-manager's module
  disabledModules = [ "services/swayidle.nix" ];

  options = {
    services.swayidle = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Whether to enable the swayidle systemd service.
      '');

      package = lib.mkPackageOption pkgs "swayidle" { };

      systemdTarget = lib.mkOption {
        type =
          types.either types.singleLineStr (types.listOf types.singleLineStr);
        default = [ "sway-session.target" ];
        description = lib.mdDoc ''
          The target, or list of targets, to use for the
          systemd unit's `Install.WantedBy` option.

          This should be the systemd target of your window manager(s).
        '';
        apply = lib.toList;
      };

      extraArgs = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [ "-w" ];
        example = lib.literalExpression ''
          ["-w" "-d"]
        '';
        description = lib.mdDoc ''
          Extra arguments to pass to swayidle at the beginning of
          the systemd unit's command line.
        '';
      };

      idleHint = lib.mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
        example = lib.literalExpression ''
          2 * 60
        '';
        description = lib.mdDoc ''
          Indicate to logind that a session is idle after
          this number of seconds. Setting this will also
          cause swayidle to call `SetIdleHint(false)` when
          run on events.
        '';
      };

      events = lib.mkOption {
        type = types.attrs;
        default = { };
        example = lib.literalExpression ''
          let
            swaylock = lib.getExe pkgs.swaylock;
          in {
            beforeSleep = ''''''
              ''${pkgs.swaylock} -f
            '''''';
            lock = ''''''
              ''${swaylock} -f --grace-no-mouse --grace 5
            '''''';
          }
        '';
        description = lib.mdDoc ''
          An attribute set with event names as keys (in camel case)
          and values as lines of a shell script. The value of each
          attribute will be run when the corresponding event
          (attribute name) is triggered.
        '';
      };

      timeouts = lib.mkOption {
        type = types.attrsOf (types.submodule typeTimeout);
        default = { };
        example = lib.literalExpression "";
        description = lib.mdDoc ''
          > Scripts defined in this option are power-supply-agnostic.
          >
          > If you are using a laptop, you may prefer to use
          > {option}`batteryTimeouts` and {option}`pluggedInTimeouts`.
          >
          > Timeout scripts defined in this option will be run
          > regardless of power state, and have no lock file.

          An attribute set of timeout definitions.
          The attribute name is the used internally to name
          shell scripts written to the store, and lock files
          if the scripts are state-dependant (in the case of
          {option}`batteryTimeouts` and {option}`pluggedInTimeouts`).

          A timeout definition is an attribute set
          of keys `timeout`, `script`, and `resumeScript`.
          Timeout is the duration of inactivity, after which
          to execute the lines of shell script specified.

          The resume script is run after activity continues
          and the session is no longer considered to be idle.
        '';
      };

      powerSupply = lib.mkOption {
        type = typeRootPath;
        default = "/sys/class/power_supply/AC";
        example = lib.literalExpression
          "/sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:37/PNP0C09:00/ACPI0003:00/power_supply/AC";
        description = lib.mdDoc ''
          The power supply device to use when determining if the
          system is plugged in to an constant power supply,
          such as an AC or a DC adapter, or a UPS device.

          This value is expected to be a `sysfs` path to a power supply
          device as described in the Linux kernel's documentation:
          <https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-power>

          Note that the only property needed is `online`.
          The system will be considered "plugged-in" when the value
          of `online` is greater than zero.

          This power device should be online when the system is plugged
          into a charger, and offline when running on battery power.

          If this device is **online**, scripts from {option}`pluggedInTimeouts`
          will be run; if this device is **offline**, scripts from
          {option}`batteryTimeouts` will run.
        '';
      };

      batteryTimeouts = lib.mkOption {
        type = types.attrsOf (types.submodule typeTimeout);
        default = { };
        example = lib.literalExpression "";
        description = lib.mdDoc ''
          > This option is only relevant for laptop users.
          > For devices that are always powered directly from
          > a constant supply, use {option}`timeouts` instead.

          Timeouts to run only when on battery power.
          See {option}`timeouts` for details.

          This is determined by checking if the `status` file in
          {option}`batteryDevice` path contains anything **other than**
          `Charging` or `Not charging`.
        '';
      };

      pluggedInTimeouts = lib.mkOption {
        type = types.attrsOf (types.submodule typeTimeout);
        default = { };
        example = lib.literalExpression "";
        description = lib.mdDoc ''
          > This option is only relevant for laptop users.
          > For devices that are always powered directly from
          > a constant supply, use {option}`timeouts` instead.

          Timeouts to run only when plugged in with an AC adapter.
          See {option}`timeouts` for details.

          This is determined by checking if the `status` file in
          {option}`batteryDevice` path contains **either**
          `Charging` or `Not charging`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (let
    # make sure this is double quoted everywhere it is used
    lockFileDir = "/var/run/user/$(id -u)/swayidle";

    mkEventArgs = name: script:
      let
        eventNames = {
          beforeSleep = "before-sleep";
          afterResume = "after-resume";
        };
      in [
        (if eventNames ? ${name} then eventNames.${name} else name)
        (pkgs.writeShellScript "swayidle-${name}" script).outPath
      ];
    mkTimeoutArgs = { scriptName, timeout, script, resumeScript }:
      [
        "timeout"
        (toString timeout)
        (pkgs.writeShellScript "swayidle-${scriptName}" script).outPath
      ] ++ lib.optionals (resumeScript != null) [
        "resume"
        (pkgs.writeShellScript "swayidle-${scriptName}-resume"
          resumeScript).outPath
      ];

    wrapCondTimeout = suffix: condition:
      { scriptName, timeout, script, resumeScript }:
      let
        scriptName' = "${scriptName}-${suffix}";
        # FIXME assumes there are no slashes in the name
        lockPath = "${lockFileDir}/${scriptName'}.lock";
      in {
        scriptName = scriptName';
        inherit timeout;
        script = ''
          if ${condition}; then
            ${script}
            ${
              lib.optionalString (resumeScript != null) ''
                mkdir -p "${lockFileDir}"
                touch "${lockPath}"
              ''
            }
          fi
        '';
        resumeScript = if resumeScript == null then
          null
        else ''
          if [ -f "${lockPath}" ]; then
            ${resumeScript}
            rm "${lockPath}"
          fi
        '';
      };

    pluggedInCond = ''[ "$(cat '${cfg.powerSupply}/online')" -gt 0 ]'';

    args = lib.flatten [
      (map lib.escapeShellArg cfg.extraArgs)

      (lib.mapAttrsToList mkEventArgs cfg.events)

      (map mkTimeoutArgs (builtins.attrValues cfg.timeouts))

      (map (x: mkTimeoutArgs (wrapCondTimeout "battery" "! ${pluggedInCond}" x))
        (builtins.attrValues cfg.batteryTimeouts))

      (map (x: mkTimeoutArgs (wrapCondTimeout "pluggedIn" "${pluggedInCond}" x))
        (builtins.attrValues cfg.pluggedInTimeouts))

      (lib.optionals (cfg.idleHint != null) [
        "idlehint"
        (toString cfg.idleHint)
      ])
    ];
  in {
    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle daemon for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
        Environment =
          [ "PATH=${lib.makeBinPath [ pkgs.bash pkgs.coreutils ]}" ];
        ExecStart =
          "${cfg.package}/bin/swayidle ${lib.concatStringsSep " " args}";
      };

      Install.WantedBy = cfg.systemdTarget;
    };
  });
}
