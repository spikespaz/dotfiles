{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.services.swayidle.alt;
in {
  options = {
    services.swayidle.alt = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Whether to enable the swayidle systemd service.
      '');

      package = lib.mkPackageOption pkgs "swayidle" {};

      systemdTarget = lib.mkOption {
        type =
          types.either types.singleLineStr
          (types.listOf types.singleLineStr);
        default = ["sway-session.target"];
        description = lib.mdDoc ''
          The target, or list of targets, to use for the
          systemd unit's `Install.WantedBy` option.

          This should be the systemd target of your window manager(s).
        '';
      };

      extraArgs = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = [];
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
        default = {};
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
        type = types.attrs;
        default = {};
        example = lib.literalExpression '''';
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
    eventNames = {
      beforeSleep = "before-sleep";
      afterResume = "after-resume";
    };
    mkEventArgs = name: script: [
      (
        if eventNames ? ${name}
        then eventNames.${name}
        else name
      )
      (pkgs.writeShellScript "swayidle-${name}" script).outPath
    ];
    mkTimeoutArgs = name: {
      timeout,
      script,
      resumeScript ? null,
    }:
      [
        "timeout"
        (toString timeout)
        (pkgs.writeShellScript "swayidle-${name}" script).outPath
      ]
      ++ lib.optionals (resumeScript != null) [
        "resume"
        (pkgs.writeShellScript "swayidle-${name}-resume" resumeScript).outPath
      ];
    args = lib.flatten [
      (map lib.escapeShellArg cfg.extraArgs)
      (lib.mapAttrsToList mkEventArgs cfg.events)
      (lib.mapAttrsToList mkTimeoutArgs cfg.timeouts)
      (lib.optionals (cfg.idleHint != null) ["idlehint" (toString cfg.idleHint)])
    ];
    targets =
      if lib.isList cfg.systemdTarget
      then cfg.systemdTarget
      else [cfg.systemdTarget];
  in {
    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle daemon for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
        Environment = ["PATH=${lib.makeBinPath [pkgs.bash]}"];
        ExecStart = "${cfg.package}/bin/swayidle -w ${lib.concatStringsSep " " args}";
      };

      Install.WantedBy = targets;
    };
  });
}
