{ self, config, pkgs, lib, ... }:
(xs: { imports = xs; }) [
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
      persistent = true;
    };

    # use a lower priority for builds
    # so that the system is still usable with the following (extreme) settings
    nix.daemonCPUSchedPolicy = "batch";
    nix.daemonIOSchedClass = "idle";

    nix.settings = rec {
      # allow the flake settings
      # accept-flake-config = true;
      # set a minimum free space so that garbage collection
      # runs more aggressively during a build
      min-free = lib.bytes.GiB 30;
      # keep the derivations from which active store paths are built
      keep-derivations = true;
      # keep the outputs (source files for example) of
      # derivations which are associated with active store paths
      keep-outputs = true;
      # divide cores between jobs and reserve some for the system
      cores = let
        # number of logical processors on the host (nproc)
        hostCores = 16;
        # number of logical cores to reserve for other processes
        reserveCores = 2;
      in (hostCores - reserveCores) / max-jobs;
      # max concurrent jobs
      max-jobs = 4;
      # allow sudo users to mark the following values as trusted
      trusted-users = [ "root" "@wheel" ];
      # only allow sudo users to manage the nix store
      allowed-users = [ "@wheel" ];
      # enable new nix command and flakes
      extra-experimental-features = [ "flakes" "nix-command" ];

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
      hostName = "intrepid";
      hostId = builtins.substring 0 8
        (builtins.hashString "md5" config.networking.hostName);

      # CloudFlare nameservers
      nameservers =
        [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];

      firewall = {
        enable = true;
        allowedTCPPorts = [
          # Web Servers
          80
          443
          # Jellyfin
          8096
          8920
          # Minecraft
          25565
          25572
        ];
        allowedUDPPorts = [
          # Minecraft
          25565
          25572
        ];
      };

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
      # error: rtw89-firmware has been removed because linux-firmware now contains it.
      # firmware = [pkgs.rtw89-firmware];

      # enable opengl just in case the compositor doesn't
      opengl.enable = true;
      opengl.driSupport32Bit = true;

      # enable the lenovo trackpoint (default) but decrease sensitivity
      trackpoint.enable = true;
      trackpoint.speed = 85;
    };

    # # gui tool for processor management
    # programs.corectrl.enable = true;
    # # sets the overdrive bit in amdgpu.ppfeaturemask
    # programs.corectrl.gpuOverclock.enable = true;
  }

  ################
  ### SERVICES ###
  ################
  {
    ### SERVICES: SSH ###

    # I do not want ssh to be easily sniffable
    # <https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/ssh/sshd.nix>
    services.openssh.enable = true;
    services.openssh.ports = [ 1948 ];
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
      drivers = with pkgs; [ gutenprint hplip ];
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

    # allow users to mount fuse filesystems with allow_other
    programs.fuse.userAllowOther = true;

    ### DEFAULT FONTS ###

    fonts = {
      fontconfig.enable = true;
      fontDir.enable = true;
      # handled by filesystem
      fontDir.decompressFonts = true;
      fonts = with pkgs; [
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
  self.nixosModules.disable-input
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

    # backlight brightness control (and keyboard, etc)
    # allows the backlight to be controlled via software
    boot.kernelParams = [ "amdgpu.backlight=0" ];
    environment.systemPackages = [ pkgs.slight ];
    services.udev.packages = [ pkgs.slight ];

    programs.disable-input-devices = {
      enable = true;
      allowedUsers = [ "jacob" ];
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

  #########################
  ### SHARED USER FILES ###
  #########################
  # enable shell completions for system packages
  {
    environment.pathsToLink = [ "/share/zsh" "/share/bash-completion" ];
  }
  # very useful /usr/share/dict/words and $WORDLIST
  # <https://en.wikipedia.org/wiki/Words_(Unix)>
  {
    environment.wordlist.enable = true;
    systemd.tmpfiles.rules = [
      "L /usr/share/dict/words - - - - ${
        lib.pipe config.environment.wordlist.lists.WORDLIST [
          (map builtins.readFile)
          (lib.concatStringsSep "\n")
          (pkgs.writeText "system-words")
        ]
      }"
    ];
  }
  # public shared directory for users of the users group
  {

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

  #####################
  ### USERS CONFIGS ###
  #####################
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
  }

  ###################
  ### PERIPHERALS ###
  ###################
  {
    hardware.openrazer = {
      enable = true;
      users = [ "jacob" ];
      devicesOffOnScreensaver = false;
    };
  }

  ######################
  ### VIRTUALIZATION ###
  ######################
  {
    boot.kernelModules = [ "kvm-amd" ];

    # virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu.swtpm.enable = true;
      qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
  }

  ###################
  ### TTY CONSOLE ###
  ###################
  {
    console.keyMap = "us";
    console.packages = [ pkgs.tamsyn ];
    console.font = "Tamsyn8x16r";
  }
]
