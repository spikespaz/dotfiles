# <https://github.com/viperML/dotfiles/tree/master/hosts/gen6>
# <https://github.com/IceDBorn/IceDOS/blob/nixos/configuration.nix>
# <https://github.com/yrashk/nix-home/blob/master/home.nix>
{ config, pkgs, ... }:
let
  nixos-hardware = builtins.fetchGit {
    url = "https://github.com/NixOS/nixos-hardware";
  };
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager";
    ref = "release-22.05";
  };
in {
  imports = [
    ./filesystems.nix
    "${nixos-hardware}/lenovo/thinkpad/p14s/amd/gen2"
    "${home-manager}/nixos"
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
      systemd-boot.configurationLimit = 5;

      timeout = 3;

      efi.efiSysMountPoint = "/boot";
      efi.canTouchEfiVariables = true;
    };
  };

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
    options = "--delete-older-than 7d";
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
    kate

    # Desktop Environment
    rofi-wayland
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.users = {
    jacob = {
      home.username = "jacob";
      home.homeDirectory = "/home/jacob";

      home.packages = with pkgs; [
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

      programs.home-manager.enable = true;

      programs.git = {
        enable = true;
        userName = "Jacob Birkett";
        userEmail = "jacob@birkett.dev";

        delta.enable = true;
      };

      programs.bat = {
        enable = true;
      };

      programs.exa = {
        enable = true;
      };

      programs.lsd = {
        enable = true;
      };

      programs.fzf = {
        enable = true;
      };

      programs.firefox = {
        enable = true;
      };

      programs.chromium = {
        enable = true;
      };

      programs.helix = {
        enable = true;
      };

      programs.neovim = {
        enable = true;
      };

      programs.hexchat = {
        enable = true;
      };

      programs.obs-studio = {
        enable = true;
      };

      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = 1;
      };

      home.stateVersion = "22.05";
    };
  };

  users.users.jacob = {
    description = "Jacob Birkett";
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "22.05";
}
