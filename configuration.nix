# <https://github.com/viperML/dotfiles/tree/master/hosts/gen6>
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
    
    zfs = {
      enableUnstable = true;
      forceImportAll = false;
      forceImportRoot = false;
    };
    
    #kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      systemd-boot.configurationLimit = 15;

      timeout = 3;

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
    enableRedistributableFirmware = true;

    cpu.amd.updateMicrocode = true;

    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;

    opengl.enable = true;
    opengl.driSupport32Bit = true;

    trackpoint.enable = true;
    trackpoint.speed = 85;
  };

  time.timeZone = "America/Phoenix";
  i18n.defaultLocale = "en_US.utf8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services = {
    xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true;

      displayManager.gdm.enable = true;
      desktopManager.xfce.enable = true;
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    printing.enable = true;

    zfs = {
      trim.enable = true;
      trim.interval = "weekly";

      autoScrub.enable = true;
      autoScrub.pools = [ "ospool" ];
      autoScrub.interval = "weekly";
    };

    #flatpak.enable = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # For ALSA support
  sound.enable = true;
  # For Flatpak support
  #xdg.portal.enable = true;
  #xdg.portal.wlr.enable = true;

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    # Essentials
    wget
    curl
    tree
    # Development
    git
    # Web Browsers
    firefox
    # File Managers
    dolphin
    # Terminals
    alacritty
    # Text Editors
    neovim
    xed-editor
    kate

    # Desktop Environment
    rofi-wayland
  ];

  users.users.jacob = {
    description = "Jacob Birkett";
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Email
      thunderbird
      # Messaging
      discord
      neochat
      # Text Editors
      vscode

      # Desktop Theming
      papirus-icon-theme
      materia-theme
      materia-kde-theme
      libsForQt5.qtstyleplugin-kvantum
    ];
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "22.05";
}

