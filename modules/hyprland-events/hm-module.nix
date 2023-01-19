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
  # TODO openlayer closelayer changefloatingmode
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
      windowFullscreen = {
        event = "fullscreen";
        vars = ["FULLSCREEN_STATE"];
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

      handlers = builtins.mapAttrs (_: {
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

              - `${lib.concatStringsSep "`\n  - `" vars}`

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
    enabledHandlers = lib.filterAttrs (_: v: v != null) cfg.handlers;

    handlerScripts =
      lib.mapAttrs' (name: text: {
        name = "__HL_HANDLER_${lib.toUpper name}";
        value = pkgs.writeShellScript "hl-handler-${name}" text;
      })
      enabledHandlers;

    listenerWrapper = pkgs.writeShellScript "hyprland-event-listener" ''
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (var: script: ''
          export ${var}=${script}
        '')
        handlerScripts
      )}

      ${lib.getExe pkgs.perl} ${./handler.pl}
    '';
  in {
    # if cfg.systemdService
    # then {
    systemd.user.services.hyprland-event-listener = {
      Unit = {
        Description = description;
        PartOf = "hyprland-session.target";
      };
      Service = {
        Type = "simple";
        ExecStart = "${listenerWrapper}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["hyprland-session.target"];
    };
    # }
    # else {
    #   wayland.windowManager.hyprland = {
    #     extraInitConfig = ''
    #       exec-once = ${wrapper}
    #     '';
    #   };
    # });
  });
}
