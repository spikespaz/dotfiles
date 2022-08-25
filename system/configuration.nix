# <https://github.com/viperML/dotfiles/tree/master/hosts/gen6>
# <https://github.com/IceDBorn/IceDOS/blob/nixos/configuration.nix>
# <https://github.com/yrashk/nix-home/blob/master/home.nix>
# <https://github.com/MatthiasBenaets/nixos-config/blob/master/flake.nix>
{ config, pkgs, nixpkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

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

  # For ALSA support
  sound.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

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

  users.users = {
    jacob = {
      description = "Jacob Birkett";
      isNormalUser = true;
      initialPassword = "password";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };

  system.stateVersion = "22.05";
}
