{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland.eventHandlers;

  description = ''
    Harness script to dispatch Hyprland IPC events to
    registered handlers from Nix configurations.
  '';

  mkEventDescription = ipcName: ipcArgs: envVars: extraText:
    lib.mdDoc (''
        Corresponds to `${ipcName}` event, with arguments:
        ${lib.concatStringsSep "\n- " ipcArgs}

        Scripts and binaries will have access to the following environment variables:
        ${lib.concatStringsSep "\n- " envVars}
      ''
      + lib.optionalString (extraText != null) "\n${extraText}"
      + ''

        Read about this event on the wiki.

        <https://wiki.hyprland.org/IPC/>
      '');

  handlerListType = types.listOf (types.oneOf [types.path types.package types.nonEmptyStr]);
in {
  options = {
    wayland.windowManager.hyprland.eventHandlers = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Enable the Hyprland IPC handlers configuration.

        ${description}
      '');

      systemdService = lib.mkEnableOption (lib.mdDoc ''
        Enable the IPC event handler to be run as a systemd service
        wanted by `hyprland-sesion.target` instead of running as an `exec-start`
        entry in the Hyprland config file.

        This is recommended if you would like to be able to
        `systemctl --user restart hyprland-event-handler` instead of restarting
        the entire Hyprland session.
      '');

      # TODO openlayer closelayer changefloatingmode
      handlers = {
        ### WINDOWS ###

        windowFocus = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "activewindow"
            ["WINDOWCLASS" "WINDOWTITLE"]
            ["HL_WINDOW_CLASS" "HL_WINDOW_TITLE"]
            null;
        };

        windowOpen = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "openwindow"
            ["WINDOWADDRESS" "WORKSPACENAME" "WINDOWCLASS" "WINDOWTITLE"]
            ["HL_WINDOW_ADDRESS" "HL_WORKSPACE_NAME" "HL_WINDOW_CLASS" "HL_WINDOW_TITLE"]
            null;
        };

        windowClose = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "closewindow"
            ["WINDOWADDRESS"]
            ["HL_WINDOW_ADDRESS"]
            null;
        };

        windowMove = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "movewindow"
            ["WINDOWADDRESS" "WORKSPACENAME"]
            ["HL_WINDOW_ADDRESS" "HL_WORKSPACE_NAME"]
            null;
        };

        windowFullscreen = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "fullscreen"
            ["<unknown>"]
            ["HL_FULLSCREEN_STATE"]
            null;
        };

        ### WORKSPACES ###

        workspaceFocus = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "workspace"
            ["WORKSPACENAME"]
            ["HL_WORKSPACE_NAME"]
            null;
        };

        workspaceCreate = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "createworkspace"
            ["WORKSPACENAME"]
            ["HL_WORKSPACE_NAME"]
            null;
        };

        workspaceDestroy = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "destroyworkspace"
            ["WORKSPACENAME"]
            ["HL_WORKSPACE_NAME"]
            null;
        };

        workspaceMove = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "moveworkspace"
            ["WORKSPACENAME" "MONNAME"]
            ["HL_WORKSPACE_NAME" "HL_MONITOR_NAME"]
            null;
        };

        ### MONITORS ###

        monitorFocus = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "focusedmon"
            ["MONNAME" "WORKSPACENAME"]
            ["HL_MONITOR_NAME" "HL_WORKSPACE_NAME"]
            null;
        };

        monitorAdd = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "monitoradded"
            ["MONITORNAME"]
            ["HL_MONITOR_NAME"]
            null;
        };

        monitorRemove = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "monitorremoved"
            ["MONITORNAME"]
            ["HL_MONITOR_NAME"]
            null;
        };

        ### MISCELLANEOUS ###

        layoutChange = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "activelayout"
            ["KEYBOARDNAME" "LAYOUTNAME"]
            ["HL_KEYBOARD_NAME" "HL_LAYOUT_NAME"]
            null;
        };

        submapChange = lib.mkOption {
          type = handlerListType;
          default = [];
          example = lib.literalExpression '''';
          description =
            mkEventDescription
            "submap"
            ["SUBMAPNAME"]
            ["HL_SUBMAP_NAME"]
            null;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (let
    # The idea here is to accept three types: path, package, and string.
    # A path is assumed to be an executable binary, a package is assumed to have
    # meta.mainProgram set to a valid binary, and a string is expected to be
    # script code.
    mkHandlerExecPath = v:
      if (builtins.typeOf v) == "path"
      then v
      else if (builtins.typeOf v) == "package"
      then lib.getExe v
      else pkgs.writeScript "" v;
    # Coerce all hs to a path, and then concat them with
    # ':' as sep, unix-style.
    mkHandlersEnvList = hs: lib.concatStringsSep ":" (map mkHandlerExecPath hs);
    mkHandlersEnvVar = name: hs: "export __HL_HANDLERS_${lib.toUpper name}='${mkHandlersEnvList hs}'";

    wrapper = pkgs.writeShellScript "hyprland-event-handler" ''
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList mkHandlersEnvVar cfg.handlers
      )}

      ${lib.getExe pkgs.perl} ${./handler.pl}
    '';
  in {
    # if cfg.systemdService
    # then {
    systemd.user.services.hyprland-event-handler = {
      Unit = {
        Description = description;
        PartOf = "hyprland-session.target";
      };
      Service = {
        Type = "simple";
        ExecStart = "${wrapper}";
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
