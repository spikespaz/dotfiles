{ lib, pkgs, config, ... }:
let
  inherit (lib) types;
  cfg = config.programs.halloy;
  yamlFormat = pkgs.formats.yaml { };
in {
  options = {
    programs.halloy = {
      enable = lib.mkEnableOption "Halloy - Rusty and Fast IRC Client";

      package = lib.mkPackageOption pkgs "halloy" { };

      settings = lib.mkOption {
        type = yamlFormat.type;
        default = { };
        description = ''
          Configuration file for Halloy,
          to be named at {path}`$HOME/.config/halloy/config.yaml`.

          See the wiki for configuration options:
          <https://github.com/squidowl/halloy/wiki/Configuration>
        '';
        example = lib.literalExpression ''
          {

            # Theme
            # - Add theme files to the themes directory and fill this with the filename
            #   without the .yaml extension to select the theme you want
            # - Default is "ferra" and provided by this application
            # - For theme examples, please refer to:
            #   https://github.com/squidowl/halloy/wiki/Themes
            theme = "ferra";

            # For all fields under server, please refer to:
            # https://github.com/squidowl/halloy/wiki/Configuration#fields
            servers = {
              # Configuration for Libera server
              liberachat = {
                # Nickname to be used on the server
                nickname = "halloy";

                # Server address
                server = "irc.libera.chat";

                # Server port number
                port = 6697;

                # Whether to use TLS
                use_tls = true;

                # Channels to join upon connecting to the server
                channels = [ "#halloy" ];
              };
            };

            # Font settings
            font = {
              # Specify the monospaced font family to use
              # - Default is Iosevka Term and provided by this application
              family = "Iosevka Term";
              # Specify the font size
              # - Default is 13
              size = 13;
            };

            # Buffer settings
            buffer = {
              # Nickname settings
              nickname = {
                # User color settings:
                # - Unique: Unique user colors [default]
                # - Solid: Solid user colors
                color = "Unique";

                # Nickname brackets:
                # - Default is empty ""
                brackets = {
                  left = "<";
                  right = ">";
                };
              };
            };

            # Timestamp settings
            timestamp = {
              # Timestamp format:
              # - Use `strftime` format (see documentation for details):
              #   https://pubs.opengroup.org/onlinepubs/007908799/xsh/strftime.html
              format = "%T";

              # Timestamp brackets:
              # - Default is empty ""
              brackets = {
                left = "[";
                right = "]";
              };
            };

            # Input visibility behaviour
            # - Always: Show input at all times [default]
            # - Focused: Only show input when the buffer is focused
            input_visibility = "Always";

            # An array of server message types that will be hidden
            # - Default: []
            # - Supported values: ["join", "part", "quit"]
            hidden_server_messages = [ ];

            # Channel buffer settings
            channel = {
              # User list settings
              users = {
                # Visible by default
                # - Default is true
                visible = true;
                # List position
                # - Left: Left side of pane
                # - Right: Right side of pane [default]
                position = "Right";
              };
            };

            # Dashboard settings
            dashboard = {
              # Default action when selecting channels in the sidebar:
              # - NewPane: Open a new pane for each unique channel [default]
              # - ReplacePane: Replace the currently selected pane
              sidebar_default_action = "NewPane";
            };

            # Notification
            # Display a OS level notification on certain events.
            #
            # For information about events and sound
            # https://github.com/squidowl/halloy/wiki/Configuration#notification
            notifications = { highlight = { enabled = true; }; };
          }
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { home.packages = [ cfg.package ]; }
    (lib.mkIf (cfg.settings != { }) {
      xdg.configFile."halloy/config.yaml".source =
        yamlFormat.generate "halloy-config.yaml" cfg.settings;
    })
  ]);
}
