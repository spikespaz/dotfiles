{ self, pkgs, lib, ... }:
(xs: { imports = xs; }) [
  ### ADMINISTRATOR UTILITIES ###
  self.nixosModules.disable-input
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

    # create device paths to disable input devices
    programs.disable-input-devices = {
      enable = true;
      allowedGroups = [ "video" ];
      # Show all event devices:
      # $ sudo evtest
      # Get information about a device:
      # $ udevadm info -a /dev/input/eventXX
      # Test by blocking a device:
      # $ sudo evtest --grab /dev/input/eventXX
      disableDevices = {
        # "AT Translated Set 2 keyboard"
        # Laptop Keyboard
        "thinkpad/keyboard" = {
          product = "0001";
          vendor = "0001";
        };
        # "ThinkPad Extra Buttons"
        # Laptop Special Function Keys
        "thinkpad/extra-buttons" = {
          product = "5054";
          vendor = "17aa";
        };
        # "TPPS/2 Elan TrackPoint"
        # TrackPoint and Touchpad Buttons
        "thinkpad/trackpoint" = {
          product = "000a";
          vendor = "0002";
        };
        # "SynPS/2 Synaptics TouchPad"
        # Laptop Touchpad
        "thinkpad/touchpad" = {
          product = "0007";
          vendor = "0002";
        };
        # # "Power Button"
        # # Power/Sleep Button
        # "thinkpad/power-button" = {
        #   product = "0001";
        #   vendor = "0000";
        # };
        # "Lid Switch"
        # Laptop Close Switch
        "thinkpad/lid-switch" = {
          product = "0005";
          vendor = "0000";
        };
      };
    };
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
    # <https://github.com/swaywm/swaylock/issues/61>
    security.pam.services.swaylock.text = ''
      auth sufficient pam_unix.so try_first_pass nullok
      auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
    '';

    # <https://github.com/swaywm/swaylock/issues/61>
    # security.pam.services.swaylock.text = ''
    #   auth sufficient ${pkgs.fprintd-grosshack}/lib/security/pam_fprintd_grosshack.so
    #   auth sufficient pam_unix.so try_first_pass nullok
    # '';
  }
]
