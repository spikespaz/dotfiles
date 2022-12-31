args @ {
  flake,
  config,
  pkgs,
  lib,
  ...
}:
(xs: {imports = xs;})
[
  #################
  ### NIX SETUP ###
  #################
  {
    # only change if you want to fix breaking changes
    system.stateVersion = "22.05";

    # set up garbage collection to run weekly,
    # removing unused packages after seven days
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.settings = {
      # allow the flake settings
      # accept-flake-config = true;
      # use four cores for enableParallelBuilding
      cores = 4;
      # allow sudo users to mark the following values as trusted
      trusted-users = ["root" "@wheel"];
      # only allow sudo users to manage the nix store
      allowed-users = ["@wheel"];
      # enable new nix command and flakes
      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];

      # TODO: Make this Flake nixConfig
      # continue building derivations if one fails
      keep-going = true;
      # show more log lines for failed builds
      log-lines = 20;
      # instances of cachix for package derivations
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://fog.cachix.org"
        "https://webcord.cachix.org"
        "https://hyprland.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "fog.cachix.org-1:FAxiA6qMLoXEUdEq+HaT24g1MjnxdfygrbrLDBp6U/s="
        "webcord.cachix.org-1:l555jqOZGHd2C9+vS8ccdh8FhqnGe8L78QrHNn+EFEs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  }
  #############################
  ### NETWORKING & WIRELESS ###
  #############################
  {
    networking = {
      hostName = "jacob-thinkpad";
      hostId = builtins.substring 0 8 (
        builtins.hashString "md5" config.networking.hostName
      );

      # CloudFlare nameservers
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];

      # networkmanager.enable = true;
      # networkmanager.wifi.backend = "iwd";
      wireless.iwd.enable = true;
    };

    hardware = {
      # enable bluetooth but turn off power by default
      bluetooth.enable = true;
      bluetooth.powerOnBoot = false;
    };
  }

  ###########################
  ### HARDWARE & FIRMWARE ###
  ###########################
  {
    ### SERVICES: FIRMWARE ###
    # firmware updater for machine hardware
    services.fwupd.enable = true;

    ### FIRMWARE ###
    hardware = {
      # enable proprietary firmware that is still redistributable
      # required for some hardware, drivers contain proprietary blobs
      enableRedistributableFirmware = true;

      # update processor firmware by loading from memory at boot
      cpu.amd.updateMicrocode = true;

      # wifi adapter
      firmware = [pkgs.rtw89-firmware];

      # enable opengl just in case the compositor doesn't
      opengl.enable = true;
      opengl.driSupport32Bit = true;

      # enable the lenovo trackpoint (default) but decrease sensitivity
      trackpoint.enable = true;
      trackpoint.speed = 85;
    };

    # gui tool for processor management
    programs.corectrl.enable = true;
    # sets the overdrive bit in amdgpu.ppfeaturemask
    programs.corectrl.gpuOverclock.enable = true;
  }

  ################
  ### SERVICES ###
  ################
  {
    ### SERVICES: SSH ###

    # I do not want ssh to be easily sniffable
    # <https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/ssh/sshd.nix>
    services.openssh.enable = true;
    services.openssh.ports = [1948];
    # TODO understand what exactly this is
    services.openssh.startWhenNeeded = true;
    # TODO perhaps set After and X-Restart-Triggers to []?

    ### SERVICES: AUTO MOUNT ###

    # storage daemon required for udiskie auto-mount
    services.udisks2.enable = true;

    ### SERVICES: WIRELESS ###

    # bluetooth
    services.blueman.enable = true;

    ### SERVICES: LOCATION ###

    location.provider = "geoclue2";
    services.geoclue2.enable = true;
  }

  #########################
  ### SERVIES: PRINTING ###
  #########################
  {
    # audio and video drivers with legacy alsa, jack, and pulse support
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    # enable cups and add some drivers for common printers
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
      ];
    };

    # required for network discovery of printers
    services.avahi = {
      enable = true;
      # resolve .local domains for printers
      nssmdns = true;
    };
  }

  #############################
  ### SERVICES: APP SANDBOX ###
  ############################
  {
    ### SERVICES: FLATPAK ###
    services.flatpak.enable = true;
    xdg.portal.enable = true;
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

    # enable fingerprint sensor
    services.fprintd.enable = true;

    # registry for linux, thanks to gnome
    programs.dconf.enable = true;

    # locale and timezone
    time.timeZone = "America/Phoenix";
    i18n.defaultLocale = "en_US.UTF-8";

    # default packages that are good to have on any system
    environment.systemPackages = import ./packages.nix args;

    # allow users to mount fuse filesystems with allow_other
    programs.fuse.userAllowOther = true;

    ### DEFAULT FONTS ###

    fonts = {
      fontconfig.enable = true;
      fontDir.enable = true;
      # handled by filesystem
      fontDir.decompressFonts = true;
      fonts = with pkgs; [
        (pkgs.ttf-ms-win11.override {acceptEula = true;})
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
    imports = [
      flake.modules.disable-input.module
    ];

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

    programs.disable-input-devices = {
      enable = true;
      allowedUsers = ["jacob"];
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

  #####################
  ### USERS CONFIGS ###
  #####################
  {
    # enable completions for system packages
    environment.pathsToLink = ["/share/zsh" "/share/bash-completion"];

    # users.mutableUsers = false;

    users.users = let
      initialPassword = "password";
    in {
      root = {
        inherit initialPassword;
      };
      jacob = {
        description = "Jacob Birkett";
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel" "libvirtd"];
        inherit initialPassword;
      };
      guest = {
        description = "Guest User";
        isNormalUser = true;
        inherit initialPassword;
      };
    };
  }

  ######################
  ### VIRTUALIZATION ###
  ######################
  {
    # virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu.swtpm.enable = true;
      qemu.ovmf.packages = [pkgs.OVMFFull.fd];
    };
  }
]
