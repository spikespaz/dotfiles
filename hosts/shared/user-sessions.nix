{ self, lib, pkgs, config, ... }:
(imports: { inherit imports; }) [
  {
    # users.mutableUsers = false;
    users.users = let initialPassword = "password";
    in {
      root = { inherit initialPassword; };
      jacob = {
        description = "Jacob Birkett";
        isNormalUser = true;
        extraGroups = [ "audio" "video" "wheel" "libvirtd" ];
        inherit initialPassword;
      };
      guest = {
        description = "Guest User";
        isNormalUser = true;
        inherit initialPassword;
      };
    };

    hardware.openrazer = {
      enable = true;
      users = [ "jacob" ];
      devicesOffOnScreensaver = false;
    };
  }
  # ### MISCELLANEOUS ###
  {
    # policy kit
    # communication between unprivileged and privileged processes
    security.polkit.enable = true;
    # auth
    services.gnome.gnome-keyring.enable = true;
    # Enable the portal daemon, but don't configure any specific portals.
    # Instead, configure specific portals in the HM configuration per-user.
    xdg.portal.enable = true;
    # To silence the warning:
    # <https://github.com/NixOS/nixpkgs/blob/ee930f9755f58096ac6e8ca94a1887e0534e2d81/nixos/modules/config/xdg/portal.nix#L119>
    xdg.portal.config.common.default = "*";
    # allow users to mount fuse filesystems with allow_other
    programs.fuse.userAllowOther = true;
    services.flatpak.enable = true;
  }
  # Allow sudo users to renice without `sudo` invocation.
  {
    security.sudo.extraRules = [{
      groups = [ "wheel" ];
      commands = [
        {
          command = lib.getExe' pkgs.util-linux "renice";
          options = [ "NOPASSWD" ];
        }
        {
          command = # this path is RO, it's safe
            "/run/current-system/sw/bin/renice";
          options = [ "NOPASSWD" ];
        }
      ];
    }];
  }
  ### SHARED USER FILES ###
  {
    # Public shared directory for users of the `users` group.
    # Type, Path, Mode, User, Group, Age, Argument
    # Alignment uses tab characters.
    systemd.tmpfiles.rules = let
      publicDir = "/home/public/share";
      allowedUsers = lib.filter (user: user.createHome && user.isNormalUser)
        (lib.attrValues config.users.users);
    in [ "d	${publicDir}		0774	root	users	10d		-" ]
    ++ (map (user: "L	${user.home}/Public		-		-		-		-		${publicDir}")
      allowedUsers);
  }
  ### GENERAL DESKTOP ###
  {
    fonts = {
      fontconfig.enable = true;
      fontDir.enable = true;
      # handled by filesystem
      fontDir.decompressFonts = true;
      packages = with pkgs; [
        (pkgs.ttf-ms-win11.override { acceptEula = true; })
        noto-fonts
        noto-fonts-extra
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        open-sans
        ubuntu_font_family
      ];
    };
  }
  ### WAYLAND ###
  self.nixosModules.uwsm
  {
    programs.uwsm.enable = true;
    services.logind.killUserProcesses = true;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            (lib.getExe pkgs.tuigreet)
            "--time"
            "--remember"
            "--remember-user-session"
            "--asterisks"
            # "--power-shutdown '${pkgs.systemd}/bin/systemctl shutdown'"
            "--sessions '${
              let
                desktops = config.services.displayManager.sessionData.desktops;
              in lib.concatStringsSep ":" [
                "${desktops}/share/xsessions"
                "${desktops}/share/wayland-sessions"
              ]
            }'"
          ];
          user = "greeter";
        };
      };
    };

    environment.systemPackages = [ pkgs.slight ];

    services.udev.packages = [ pkgs.slight ];

    # Fingerprint support is provided by #49.
    # `login` should include an `auth` line for fprintd if it is installed.
    security.pam.services.swaylock.text = ''
      auth include login
    '';

    # <https://github.com/swaywm/swaylock/issues/61>
    # security.pam.services.swaylock.text = ''
    #   auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
    #   auth sufficient pam_unix.so try_first_pass nullok
    # '';
  }
  ### HYPRLAND ###
  (let
    hyprlandUserSessions = lib.pipe self.homeConfigurations [
      (lib.mapAttrsToList (configName: output:
        let userAtHost = lib.birdos.parseUserAtHost configName;
        in if userAtHost == null then
          { }
        else {
          inherit (userAtHost) user host;
          package =
            output.config.wayland.windowManager.hyprland.finalPackage or null;
        }))
      (lib.filter ({ user ? null, host ? null, package ? null }:
        (lib.elem user (builtins.attrNames config.users.users)) # #
        && host == config.networking.hostName && package != null))
      (lib.mapListToAttrs ({ user, package, ... }: {
        name = "${user}-${package.pname}";
        value = {
          name = "${user} - ${package.pname} (${package.version})";
          comment = lib.attrByPath [ "meta" "description" ] null package;
          exec = "${lib.getExe package} &> /dev/null";
        };
      }))
    ];
  in { programs.uwsm.desktopSessions = hyprlandUserSessions; })
]
