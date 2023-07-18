{ self, config, lib, pkgs, inputs, ... }:
let
  sessionData = config.services.xserver.displayManager.sessionData.desktops;
  sessionPath = lib.concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];
  hyprlandPackage = pkgs.hyprland;
in {
  imports = [ self.nixosModules.greetd ];

  # needed to get the .desktop file copied
  services.xserver.displayManager.sessionPackages =
    [ config.services.greetd.sessionData ];

  services.greetd.sessions = {
    hyprland = {
      name = "Hyprland Compositor";
      comment = "Wayland tiling compositor that doesn't sacrifice on looks.";
      script = ''
        ${lib.getExe hyprlandPackage} &> /dev/null
      '';
    };
  };

  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      default_session = {
        command = lib.concatStringsSep " " [
          (lib.getExe pkgs.greetd.tuigreet)
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          # "--power-shutdown '${pkgs.systemd}/bin/systemctl shutdown'"
          "--sessions '${sessionPath}'"
        ];
        user = "greeter";
      };
    };
  };
}
