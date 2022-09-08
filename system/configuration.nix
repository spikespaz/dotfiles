args @ { config, pkgs, nixpkgs, dotpkgs, ... }: {
  nixpkgs.config = {
    # allow packages that have proprietary licenses
    allowUnfree = true;
    # packages that are marked as broken; usually just incompatible
    # with complicated setups, or with popular software
    # needed for zfs on recent linux kernel
    allowBroken = true;
  };

  # configure experimenta; support for flakes,
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # set up garbage collection to run weekly,
  # removing unused packages after seven days
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
    earlySetup = true;
  };

  # systemd pivots to ramfs on shutdown
  # this is so that the root fs can be unmounted safely
  # it is not worth my time, I live on the edge
  # systemd.shutdownRamfs.enable = false;

  boot = {
    kernelModules = [ "kvm-amd" ];

    # configure plymouth theme
    # <https://github.com/adi1090x/plymouth-themes>
    plymouth = let
      pack = 3;
      theme = "hud_3";
    in {
      enable = true;
      themePackages = [
        (dotpkgs.pkgs.plymouth-themes.override { inherit pack theme; })
      ];
      inherit theme;
    };

    # make the boot quiet
    consoleLogLevel = 3;
    initrd.verbose = false;
    
    kernelParams = [
      "amdgpu"
      "fbcon=nodefer"
      "logo.nologo"
      "quiet"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "vt.global_cursor_default=0"
      "vt.handoff=7"
    ];

    initrd.kernelModules = [ "amdgpu" "nvme" ];
    initrd.availableKernelModules = [
      "ehci_pci" "xhci_pci" "usb_storage"
      "usbhid" "sd_mod" "rtsx_pci_sdmmc"
    ];

    initrd.systemd.strip = false;
    initrd.systemd.enable = true;

    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      systemd-boot.configurationLimit = 5;

      # need to hold space to get the boot menu to appear
      timeout = 0;

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
    # enable proprietary firmware that is still redistributable
    # required for some hardware, drivers contain proprietary blobs
    enableRedistributableFirmware = true;

    # update processor firmware by loading from memory at boot
    cpu.amd.updateMicrocode = true;

    # enable bluetooth but turn off power by default
    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;

    # enable opengl just in case the compositor doesn't
    opengl.enable = true;
    opengl.driSupport32Bit = true;

    # enable the lenovo trackpoint (default) but decrease sensitivity
    trackpoint.enable = true;
    trackpoint.speed = 85;
  };

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

  # storage daemon required for udiskie auto-mount
  services.udisks2.enable = true;

  # firmware updater for machine hardware
  services.fwupd.enable = true;

  services.flatpak.enable = true;

  # cross-desktop group; they make specifications
  # for what ceratin environment variables should be
  # <https://github.com/fufexan/dotfiles/blob/785b65436f5849a8dea175d967d901159f689edd/modules/desktop.nix#L153>
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  # <https://github.com/swaywm/swaylock/blob/master/pam/swaylock>
  security.pam.services.swaylock.text = "auth include login";

  # policy kit;
  # communication between unpriviledged and proviledged processes
  security.polkit.enable = true;

  # registry for linux, thanks to gnome
  programs.dconf.enable = true;

  # locale and timezone
  time.timeZone = "America/Phoenix";
  i18n.defaultLocale = "en_US.UTF-8";

  # default packages that are good to have on any system
  environment.systemPackages = import ./packages.nix args;

  # allow users to mount fuse filesystems with allow_other
  programs.fuse.userAllowOther = true;

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

  users.users = {
    jacob = {
      description = "Jacob Birkett";
      isNormalUser = true;
      initialPassword = "password";
      extraGroups = [ "networkmanager" "wheel" "video" ];
    };
  };

  system.stateVersion = "22.05";
}
