{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.services.swayidle.alt;

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
in {
  options = {
    services.swayidle.alt = {
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
          An attribute set of timeout definitions.
          The attribute name is the used internally to name
          shell scripts written to the store.

          A timeout definition is an attribute set
          of keys `timeout`, `script`, and `resumeScript`.
          Timeout is the duration of inactivity, after which
          to execute the lines of shell script specified.

          The resume script is run after activity continues
          and the session is no longer considered to be idle.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (let
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
    args = lib.flatten [
      (map lib.escapeShellArg cfg.extraArgs)
      (lib.mapAttrsToList mkEventArgs cfg.events)
      (map mkTimeoutArgs (builtins.attrValues cfg.timeouts))
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

      Install.WantedBy = lib.toList cfg.systemdTarget;
    };
  });
}
