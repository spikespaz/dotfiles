{ self, lib, pkgs, config, ... }:
lib.mkMerge [
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
    # public shared directory for users of the users group
    systemd.tmpfiles.rules = let publicDir = "/home/public/share";
    in lib.pipe config.users.users [
      lib.attrValues
      (builtins.filter (user: user.createHome && user.isNormalUser))
      # if changed fix alignment with \t
      #             Type   Path            Mode User Group Age Argument
      (map (user: [ "L	${user.home}/Public		-		-		-		-		${publicDir}" ]))
      lib.concatLists
      (links: [ "d	${publicDir}		0666	root	users	10d		-" ] ++ links)
    ];
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
  {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
    xdg.portal.configPackages = [ pkgs.hyprland ];
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
]
