# <https://github.com/viperML/dotfiles/blob/hosts/gen6/configuration.nix>
# <https://github.com/IceDBorn/IceDOS/blob/nixos/configuration.nix>
{ config, pkgs, ... }: {
  imports = [
    "${builtins.fetchGit { url = https://github.com/NixOS/nixos-hardware.git; }}/lenovo/thinkpad/p14s/amd/gen2"
  ];
  
  nixpkgs.config.allowBroken = true;  
  nixpkgs.config.allowUnfree = true;

  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelModules = [
        "zfs"
        "kvm-amd"
      ];


    initrd = {
      availableKernelModules = [
        "nvme"
        "ehci_pci"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
    };

    extraModulePackages = [ ];
    
    zfs = {
      enableUnstable = true;
      forceImportAll = false;
      forceImportRoot = false;
    };
    
    #kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    
    loader = {
      systemd-boot.enable = true;
      efi.efiSysMountPoint = "/boot";
      efi.canTouchEfiVariables = true;
    };
  };
  
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=0755" ];
    };
    "/etc/nixos" = {
      device = "ospool/etc/nixos";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/var/lib" = {
      device = "ospool/var/lib";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/var/log" = {
      device = "ospool/var/log";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/var/cache" = {
      device = "ospool/var/cache";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/nix" = {
      device = "ospool/nix";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/home" = {
      device = "ospool/home";
      fsType = "zfs";
      options = [ "zfsutil" "X-mount.mkdir" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
  
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking = {
    hostName = "jacob-thinkpad";
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    networkmanager.enable = true;
  };
  
  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
    };
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      pools = [ "ospool" ];
      interval = "weekly";
    };
    trim.enable = true;
  };

  time.timeZone = "America/Phoenix";

  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings = {
      LC_MEASUREMENT = "es_ES.utf8";
    };
  };

  # Select internationalisation properties.
  #i18n.defaultLocale = "en_US.UTF-8";
  #console = {
  #  font = "Lat2-Terminus16";
  #  keyMap = "us";
  #  useXkbConfig = true; # use xkbOptions in tty.
  #};

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.mate.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jacob = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Email
      thunderbird
      # Messaging
      discord
      neochat
      # Text Editors
      vscode
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    # Web Browsers
    firefox
    # File Managers
    dolphin
    # Terminals
    konsole
    yakuake
    alacritty
    # Text Editors
    neovim
    kate

    # Blah
    rofi-wayland

    # Desktop Theming
    pkgs.papirus-icon-theme
    pkgs.materia-theme
    pkgs.materia-kde-theme
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

