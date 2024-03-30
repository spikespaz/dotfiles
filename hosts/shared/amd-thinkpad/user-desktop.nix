{ self, pkgs, lib, ... }:
(xs: { imports = xs; }) [
  ### ADMINISTRATOR UTILITIES ###
  {
    environment.systemPackages = [ pkgs.slight ];
    services.udev.packages = [ pkgs.slight ];

    # Allow sudo users to renice without `sudo` invocation.
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

  ###########################
  ### DESKTOP ENVIRONMENT ###
  ###########################
  {
    # policy kit;
    # communication between unpriviledged and proviledged processes
    security.polkit.enable = true;

    # auth
    services.gnome.gnome-keyring.enable = true;

    ### DEFAULT FONTS ###

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

  ####################################
  ### DESKTOP ENVIRONMENT: WAYLAND ###
  ####################################
  {
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
