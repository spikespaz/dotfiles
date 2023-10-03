{ self, tree, config, lib, pkgs, inputs, ... }:
let
  hyprlandUserSessions = lib.pipe self.homeConfigurations [
    (lib.mapAttrs (_: attrs:
      attrs.config.wayland.windowManager.hyprland.finalPackage or null))
    (lib.filterAttrs (_: package: package != null))
    (lib.mapAttrs' (user: package: {
      name = "${user}-${package.pname}";
      value = {
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

