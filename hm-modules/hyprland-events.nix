{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland.eventListener;

  description = ''
    Event listener for Hyprland's `socket2` IPC protocol.
  '';

  # prefix to avoid any potential collisions
  eventVarPrefix = "HL_";

  eventHandlers =
    lib.mapAttrs (
      _: attrs @ {vars, ...}:
        attrs // {vars = map (v: eventVarPrefix + v) vars;}
    ) {
      ### WINDOWS ###
      windowFocus = {
        event = "activewindow";
        vars = ["WINDOW_CLASS" "WINDOW_TITLE"];
      };
      windowOpen = {
        event = "openwindow";
        vars = ["WINDOW_ADDRESS" "WORKSPACE_NAME" "WINDOW_CLASS" "WINDOW_TITLE"];
      };
      windowClose = {
        event = "movewindow";
        vars = ["WINDOW_ADDRESS"];
      };
      windowMove = {
        event = "movewindow";
        vars = ["WINDOW_ADDRESS" "WORKSPACE_NAME"];
      };
      windowFloat = {
        event = "changefloatingmode";
        vars = ["WINDOW_ADDRESS" "FLOAT_STATE"];
      };
      windowFullscreen = {
        event = "fullscreen";
        vars = ["FULLSCREEN_STATE"];
      };

      ### LAYERS ###
      layerOpen = {
        event = "openlayer";
        vars = ["LAYER_NAMESPACE"];
      };
      layerClose = {
        event = "closelayer";
        vars = ["LAYER_NAMESPACE"];
      };

      ### WORKSPACES ###
      workspaceFocus = {
        event = "workspace";
        vars = ["WORKSPACE_NAME"];
      };
      workspaceCreate = {
        event = "createworkspace";
        vars = ["WORKSPACE_NAME"];
      };
      workspaceDestroy = {
        event = "destroyworkspace";
        vars = ["WORKSPACE_NAME"];
      };
      workspaceMove = {
        event = "moveworkspace";
        vars = ["WORKSPACE_NAME" "MONITOR_NAME"];
      };

      ### MONITORS ###
      monitorFocus = {
        event = "focusedmon";
        vars = ["MONITOR_NAME" "WORKSPACE_NAME"];
      };
      monitorAdd = {
        event = "monitoradded";
        vars = ["MONITOR_NAME"];
      };
      monitorRemove = {
        event = "monitorremoved";
        vars = ["MONITOR_NAME"];
      };

      ### MISCELLANEOUS ###
      layoutChange = {
        event = "activelayout";
        vars = ["KEYBOARD_NAME" "LAYOUT_NAME"];
      };
      submapChange = {
        event = "submap";
        vars = ["SUBMAP_NAME"];
      };
    };
in {
  options = {
    wayland.windowManager.hyprland.eventListener = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Enable the Hyprland IPC listener & handlers configuration.

        See the documentation for each event on the Hyprland wiki:
        <https://wiki.hyprland.org/IPC/>.

        Events and variables have been renamed
        to satisfy your mental disorders.

        ${description}
      '');

      systemdService = lib.mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Enable the IPC event listener to be run as a systemd service
          wanted by `hyprland-sesion.target` instead of running as an
          `exec-start` entry in the Hyprland config file.

          This is recommended if you would like to be able to
          `systemctl --user restart hyprland-event-handler`
          (for instance, when testing changes) instead of restarting
          the entire Hyprland session.
        '';
      };

      handler = builtins.mapAttrs (_: {
        event,
        vars,
        ...
      }:
        lib.mkOption {
          type = types.nullOr types.lines;
          default = null;
          description = lib.mdDoc ''
            IPC socket event name: `${event}`

            Environment variables:

            ${lib.concatMapStrings (v: " - `${v}`\n") vars}

            The above environment variables can be used in lines of
            shell code declared by this option. They are exported such that
            any subprocesses called by this handler
            script will also recieve them. The order they are listed in
            agrees with the positional data shown for the `${event}` event
            as shown on the wiki.

            <https://wiki.hyprland.org/IPC/>
          '';
        })
      eventHandlers;
    };
  };

  config = lib.mkIf cfg.enable (let
    handlerInfos = lib.pipe cfg.handler [
      (lib.filterAttrs (_: v: v != null))
      (lib.mapAttrs (n: text: {
        inherit (builtins.getAttr n eventHandlers) event vars;
        script = pkgs.writeShellScript "hyprland-${n}-handler" text;
      }))
    ];

    # TODO vaxry, window titles can have commas in them...
    mkEventRegex = {
      event,
      vars,
      ...
    }: "^${event}\\>\\>${lib.concatStringsSep "," (
      builtins.genList (_: "(.+)") (builtins.length vars)
    )}$";

    enumerate = f: l: lib.zipListsWith f (lib.range 0 (builtins.length l)) l;

    listenerScript = pkgs.writeShellScript "hyprland-event-listener" ''
      set -o pipefail

      socket="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
      echo "INFO: opening socket: $socket"

      ${pkgs.netcat}/bin/nc -U "$socket" | while read -r line; do
        ${lib.concatStrings (lib.mapAttrsToList (_: info: ''
          if [[ "$line" =~ ${mkEventRegex info} ]]; then
            ${lib.concatStringsSep "\n  " (
            enumerate
            (i: v: "export ${v}=\"\${BASH_REMATCH[${toString (i + 1)}]}\"")
            info.vars
          )}
            ${info.script}
            exit=$?
            if [[ $exit -ne 0 ]]; then
              echo "ERROR: exited $exit: ''${BASH_REMATCH[0]}"
            else
              echo "SUCCESS: handled: ''${BASH_REMATCH[0]}"
            fi
            continue
          fi
        '')
        handlerInfos)}

        echo "INFO: unhandled event: $line"
      done || echo "ERROR: main pipeline failed, exit: $?"
    '';
  in
    lib.mkMerge [
      (lib.mkIf cfg.systemdService {
        systemd.user.services.hyprland-event-listener = {
          Unit = {
            Description = description;
            PartOf = "hyprland-session.target";
          };
          Service = {
            Type = "simple";
            ExecStart = "${listenerScript}";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = ["hyprland-session.target"];
        };
      })
      (lib.mkIf (!cfg.systemdService) {
        wayland.windowManager.hyprland = {
          extraInitConfig = ''
            exec-once = ${listenerScript}
          '';
        };
      })
    ]);
}
