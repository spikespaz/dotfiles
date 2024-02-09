{ self, config, lib, pkgs, ... }:
let
  hyprlandUserSessions = lib.pipe self.homeConfigurations [
    (lib.mapAttrsToList (configName: attrs:
      let userAtHost = lib.birdos.parseUserAtHost configName;
      in if userAtHost == null then
        { }
      else {
        inherit (userAtHost) user host;
        package =
          attrs.config.wayland.windowManager.hyprland.finalPackage or null;
      }))
    (lib.filter ({ user ? null, host ? null, package ? null }:
      host == config.networking.hostName && package != null))
    (lib.mapListToAttrs ({ user, package, ... }: {
      name = "${user}-${package.pname}";
      value = {
        name = "${user} - ${package.pname} (${package.version})";
        comment = lib.attrByPath [ "meta" "description" ] null package;
        script = ''
          ${lib.getExe package} &> /dev/null
        '';
      };
    }))
  ];
in {
  imports = [ self.nixosModules.greetd ];

  services.greetd = {
    enable = true;
    vt = 2;
    sessions = lib.updates [ hyprlandUserSessions ];
    settings = {
      default_session = {
        command = lib.concatStringsSep " " [
          (lib.getExe pkgs.greetd.tuigreet)
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          # "--power-shutdown '${pkgs.systemd}/bin/systemctl shutdown'"
          "--sessions '${config.services.greetd.sessionPath}'"
        ];
        user = "greeter";
      };
    };
  };
}

