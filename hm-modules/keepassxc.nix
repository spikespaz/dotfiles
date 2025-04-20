# TODO maybe?
# <https://gist.github.com/dAnjou/b99f55de34b90246f381e71e3c8f9262>
# <https://github.com/keepassxreboot/keepassxc/issues/613>
{ config, lib, ... }:
let
  inherit (lib) types;

  service = config.services.keepassxc;
  program = config.programs.keepassxc;
in {
  options = {
    services.keepassxc = {
      enable = lib.mkEnableOption "KeePassXC Service";

      package = lib.mkOption {
        type = types.package;
        description = ''
          Uses the program configuration's package by default.
        '';
        defaultText = ''
          {option}`config.programs.keepassxc.package`
        '';
      };
    };

    programs.keepassxc = {
      browserIntegration.firefox = lib.mkEnableOption ''
        Create the native messaging manifest in {path}`$HOME/.mozilla/native-messaging-hosts`,
        required for integration with the browser extension.

        Enabling this option is required if you use declarative {option}`settings`.

        Note that this also requires `Browser.Enabled = true` in {option}`settings`,
        or enable it via the GUI.
      '';
    };
  };

  config = lib.mkMerge [
    { services.keepassxc.package = lib.mkDefault program.package; }

    (lib.mkIf ((program.enable || service.enable)
      && program.browserIntegration.firefox) {
        home.file.".mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json".text =
          builtins.toJSON {
            allowed_extensions = [ "keepassxc-browser@keepassxc.org" ];
            description = "KeePassXC integration with native messaging support";
            name = "org.keepassxc.keepassxc_browser";
            path = lib.getExe' service.package "keepassxc-proxy";
            type = "stdio";
          };
      })

    (lib.mkIf service.enable {
      systemd.user.services.keepassxc = {
        Unit = {
          Description = service.package.meta.description;
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          KillMode = "process";
          ExecStart = lib.getExe' service.package "keepassxc";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    })
  ];
}
