{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.programs.hyprland.eventHandlers;

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
in {
  options = {
    enable = lib.mkEnableOption (lib.mdDoc ''
      Enable the Hyprland IPC handlers configuration.
    '');

    enableSystemd = lib.mkEnableOption (lib.mdDoc ''
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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
        type = types.listOf (types.oneOf [types.lines types.path]);
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

  config = lib.mkIf cfg.enable {};
}
