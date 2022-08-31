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
    zfs.enableUnstable = true;

    kernelModules = [
      "kvm-amd"
    ];

    initrd.availableKernelModules = [
      "nvme"
      "ehci_pci"
      "xhci_pci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    
    #kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      systemd-boot.configurationLimit = 5;

      timeout = 1;

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

    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
      ];
    };

    # required for network discovery of printers
    avahi = {
      enable = true;
      # resolve .local domains for printers
      nssmdns = true;
    };

    udisks2.enable = true;

    flatpak.enable = true;
  };

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
    btop
    git
    # Web Browsers
    firefox
    # Media Viewers
    qimgv
    # File Managers
    libsForQt5.dolphin
    libsForQt5.ark
    # Terminals
    alacritty
    # Text Editors
    neovim
    kate
  ];

  environment.sessionVariables = {
    # Qt doesn't work well with wayland on wlroots compositors.
    # Run programs under Xwayland to ensure that popup menus are visible.
    # QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORM = "xcb";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GTK_USE_PORTAL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    XCURSOR_SIZE = "24";
  };

  users.users = {
    jacob = {
      description = "Jacob Birkett";
      isNormalUser = true;
      initialPassword = "password";
      extraGroups = [ "networkmanager" "wheel" ];
    };
  };

  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    fonts = with pkgs; [
      corefonts
      noto-fonts
      open-sans
      ubuntu_font_family
    ];
  };

  system.stateVersion = "22.05";
}
