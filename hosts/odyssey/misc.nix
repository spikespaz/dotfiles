{ self, config, pkgs, lib, inputs, ... }:
(xs: { imports = xs; }) [
  ### TOP-LEVEL NIXOS MODULES ###
  inputs.ragenix.nixosModules.default

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
        "https://hyprland.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "fog.cachix.org-1:FAxiA6qMLoXEUdEq+HaT24g1MjnxdfygrbrLDBp6U/s="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    ### NIX ACCESS-TOKENS ###
    age.secrets.nix-access-tokens-github.file =
      "${self}/secrets/root.nix-access-tokens-github.age";
    nix.extraOptions = ''
      !include ${config.age.secrets.nix-access-tokens-github.path}
    '';
  }

  #############################
  ### NETWORKING & WIRELESS ###
  #############################
  {
    networking = {
      hostName = "odyssey";
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
    };
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

    ### SERVICES: LOCATION ###

    location.provider = "geoclue2";
    services.geoclue2.enable = true;
  }

  #########################
  ### SERVIES: PRINTING ###
  #########################
  {
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

  ##########################
  ### SYSTEM ENVIRONMENT ###
  ##########################
  {
    # tty config
    console.keyMap = "us";
    console.packages = [ pkgs.tamsyn ];
    console.font = "Tamsyn10x20r";
    # enable shell completions for system packages
    environment.pathsToLink = [ "/share/zsh" "/share/bash-completion" ];

    # registry for linux, thanks to gnome
    programs.dconf.enable = true;

    # very useful /usr/share/dict/words and $WORDLIST
    # <https://en.wikipedia.org/wiki/Words_(Unix)>
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
  ### PERIPHERALS ###
  {
    hardware.openrazer = {
      enable = true;
      users = [ "jacob" ];
      devicesOffOnScreensaver = false;
    };
  }
  ### VIRTUALIZATION ###
  {
    boot.kernelModules = [ "kvm-amd" ];

    # virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu.swtpm.enable = true;
      qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  }

  ########################
  ### USER ENVIRONMENT ###
  ########################
  {
    # allow users to mount fuse filesystems with allow_other
    programs.fuse.userAllowOther = true;
    # locale and timezone
    time.timeZone = "America/Phoenix";
    i18n.defaultLocale = "en_US.UTF-8";

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
    xdg.portal.configPackages = [ pkgs.hyprland ];
    services.flatpak.enable = true;
  }
  ### USERS CONFIGS ###
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
  ### SHARED USER FILES ###
  {
    # public shared directory for users of the users group
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
]
