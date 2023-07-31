{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland.eventListener;

  description = ''
    Event listener for Hyprland's `socket2` IPC protocol.
  '';

  # Takes a list of event handler name/variable mappings,
  # and prefixes each string in `vars` with `prefix`.
  #
  # For example, when `prefix` is `"HL_"`,
  # the `vars` list `["WINDOW_CLASS" "WINDOW_TITLE"]`
  # will be turned into `["HL_WINDOW_CLASS" "HL_WINDOW_TITLE"]`.
  #
  # This prefix is added to reduce the chance of collisions in
  # bash scripts.
  addEventVarPrefixes = prefix:
    lib.mapAttrs
    (_: attrs@{ vars, ... }: attrs // { vars = map (v: prefix + v) vars; });

  # prefix to avoid any potential collisions
  eventHandlers = addEventVarPrefixes "HL_" {
    ### WINDOWS ###
    windowFocus = {
      event = "activewindow";
      vars = [ "WINDOW_CLASS" "WINDOW_TITLE" ];
    };
    windowFocusV2 = {
      event = "activewindowv2";
      vars = [ "WINDOW_ADDRESS" ];
    };
    windowOpen = {
      event = "openwindow";
      vars =
        [ "WINDOW_ADDRESS" "WORKSPACE_NAME" "WINDOW_CLASS" "WINDOW_TITLE" ];
    };
    windowClose = {
      event = "movewindow";
      vars = [ "WINDOW_ADDRESS" ];
    };
    windowMove = {
      event = "movewindow";
      vars = [ "WINDOW_ADDRESS" "WORKSPACE_NAME" ];
    };
    windowFloat = {
      event = "changefloatingmode";
      vars = [ "WINDOW_ADDRESS" "FLOAT_STATE" ];
    };
    windowFullscreen = {
      event = "fullscreen";
      vars = [ "FULLSCREEN_STATE" ];
    };
    windowMinimize = {
      event = "minimize";
      vars = [ "WINDOW_ADDRESS" "MINIMIZE_STATE" ];
    };
    windowUrgent = {
      event = "urgent";
      vars = [ "WINDOW_ADDRESS" ];
    };
    windowTitle = {
      event = "windowtitle";
      vars = [ "WINDOW_ADDRESS" ];
    };

    ### LAYERS ###
    layerOpen = {
      event = "openlayer";
      vars = [ "LAYER_NAMESPACE" ];
    };
    layerClose = {
      event = "closelayer";
      vars = [ "LAYER_NAMESPACE" ];
    };

    ### WORKSPACES ###
    workspaceFocus = {
      event = "workspace";
      vars = [ "WORKSPACE_NAME" ];
    };
    workspaceCreate = {
      event = "createworkspace";
      vars = [ "WORKSPACE_NAME" ];
    };
    workspaceDestroy = {
      event = "destroyworkspace";
      vars = [ "WORKSPACE_NAME" ];
    };
    workspaceMove = {
      event = "moveworkspace";
      vars = [ "WORKSPACE_NAME" "MONITOR_NAME" ];
    };

    ### MONITORS ###
    monitorFocus = {
      event = "focusedmon";
      vars = [ "MONITOR_NAME" "WORKSPACE_NAME" ];
    };
    monitorAdd = {
      event = "monitoradded";
      vars = [ "MONITOR_NAME" ];
    };
    monitorRemove = {
      event = "monitorremoved";
      vars = [ "MONITOR_NAME" ];
    };

    ### MISCELLANEOUS ###
    layoutChange = {
      event = "activelayout";
      vars = [ "KEYBOARD_NAME" "LAYOUT_NAME" ];
    };
    submapChange = {
      event = "submap";
      vars = [ "SUBMAP_NAME" ];
    };
    screencastChange = {
      event = "screencast";
      vars = [ "SCREENCAST_STATE" "SCREENCAST_OWNER" ];
    };
  };
in {
  options = {
    wayland.windowManager.hyprland.eventListener = {
      enable = lib.mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Enable the Hyprland IPC listener & handlers configuration.

          See the documentation for each event on the Hyprland wiki:
          <https://wiki.hyprland.org/IPC/>.

          Events and variables have been renamed
          to satisfy your mental disorders.

          ${description}
        '';
      };

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

      handler = builtins.mapAttrs (_:
        { event, vars, ... }:
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
        }) eventHandlers;
    };
  };

  config = let
    # Turn each value in `cfg.handler` into an attrset
    # saturated with `event` and `vars` from `eventHandlers`.
    # The existing value (string) will be kept as `script`.
    handlerInfos = lib.pipe cfg.handler [
      # remove handlers which are null
      (lib.filterAttrs (_: v: v != null))
      # map each handler name and value
      # to have a value of `{event, vars, script}`
      # where `event` and `vars` are from the attribute in
      # `eventHandlers` of the same name.
      (lib.mapAttrs (n: text: {
        inherit (builtins.getAttr n eventHandlers) event vars;
        script = pkgs.writeShellScript "hyprland-${n}-handler" text;
      }))
    ];

    # Given an attrset from `handlerInfos`, create a regex pattern
    # to match the expected socket message, the entire line including parameters.
    # TODO vaxry, window titles can have commas in them...
    mkEventRegex = { event, vars, ... }:
      "^${event}\\>\\>${
        lib.concatStringsSep ","
        (builtins.genList (_: "(.+)") (builtins.length vars))
      }$";

    # This script is used in a systemd service that is `PartOf`
    # `hyprland-session.target`.
    # It is itself the event listener. It opens the socket, and
    # forever reads the lines, branching out to a handler script
    # if the line matches a pattern created from an event's name
    # and parameter list.
    listenerScript = pkgs.writeShellScript "hyprland-event-listener" ''
      set -o pipefail

      socket="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
      echo "INFO: opening socket: $socket"

      ${pkgs.netcat}/bin/nc -U "$socket" | while read -r line; do
        ${
          lib.concatStrings (lib.mapAttrsToList (_: info: ''
            if [[ "$line" =~ ${mkEventRegex info} ]]; then
              ${
                lib.concatStringsSep "\n  " (lib.imap0 (i: v:
                  ''export ${v}="''${BASH_REMATCH[${toString (i + 1)}]}"'')
                  info.vars)
              }
              ${info.script}
              exit=$?
              if [[ $exit -ne 0 ]]; then
                echo "ERROR: exited $exit: ''${BASH_REMATCH[0]}"
              else
                echo "SUCCESS: handled: ''${BASH_REMATCH[0]}"
              fi
              continue
            fi
          '') handlerInfos)
        }

        echo "INFO: unhandled event: $line"
      done || echo "ERROR: main pipeline failed, exit: $?"
    '';
  in lib.mkIf (cfg.enable && cfg.handler != { }) (lib.mkMerge [
    # If it is a systemd service,
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
        Install.WantedBy = [ "hyprland-session.target" ];
      };
    })
    # Otherwise use an `execOnce` line in the Hyprland config.
    # Requires the `extraInitConfig` to be specified by my (Jacob)
    # `nix/hm-module/config.nix` in my Hyprland fork.
    (lib.mkIf (!cfg.systemdService) {
      wayland.windowManager.hyprland = {
        # extraInitConfig = ''
        extraConfig = ''
          exec-once = ${listenerScript}
        '';
      };
    })
  ]);
}
