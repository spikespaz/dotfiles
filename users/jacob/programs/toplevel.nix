{ config, pkgs, lib, ... }: {
  ####################
  ### WEB BROWSERS ###
  ####################

  chromium = { programs.chromium.enable = true; };

  microsoft-edge = {
    home.packages = [
      # TODO pull-request
      (pkgs.microsoft-edge.overrideAttrs {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postFixup = ''
          wrapProgram $out/opt/microsoft/msedge/microsoft-edge \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
        '';
      })
    ];
  };

  #################################
  ### COMMUNICATION & MESSAGING ###
  #################################

  mailspring = { home.packages = [ pkgs.mailspring ]; };

  thunderbird = {
    programs.thunderbird = {
      enable = true;

      settings = {
        # "app.donation.eoy.version.viewed" = 1;
        "mail.openpgp.allow_external_gnupg" = false;
      };

      profiles."jacob.default" = {
        isDefault = true;
        # name = "jacob-default";
      };
    };
  };

  # bluemail = {
  #   home.packages = [pkgs.bluemail];
  # };

  hexchat = {
    programs.hexchat = {
      enable = true;
      # overwriteConfigFiles = true;
      theme = pkgs.fetchzip {
        url = "https://dl.hexchat.net/themes/Monokai.hct#Monokai.zip";
        sha256 = "sha256-WCdgEr8PwKSZvBMs0fN7E2gOjNM0c2DscZGSKSmdID0=";
        stripRoot = false;
      };
    };
  };

  telegram = { home.packages = [ pkgs.tdesktop ]; };

  matrix = { home.packages = [ pkgs.libsForQt5.neochat ]; };

  ######################
  ### MEDIA CREATION ###
  ######################

  obs-studio = {
    programs.obs-studio.enable = true;
    programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-move-transition
      obs-backgroundremoval
    ];
    # needed for screen selection on wayland
    home.packages = [ pkgs.slurp ];
  };

  tools.video-editing = {
    home.packages = with pkgs; [ libsForQt5.kdenlive handbrake ffmpeg ];
  };

  tools.image-editing = { home.packages = with pkgs; [ pinta gimp ]; };

  #########################
  ### MEDIA CONSUMPTION ###
  #########################

  tidal = { home.packages = [ pkgs.tidal-hifi ]; };

  #################################
  ### OFFICE & WRITING SOFTWARE ###
  #################################

  onlyoffice = { home.packages = [ pkgs.onlyoffice-bin ]; };
  libreoffice = { home.packages = [ pkgs.libreoffice-qt ]; };
  apostrophe = { home.packages = [ pkgs.apostrophe ]; };

  ##########################
  ### TERMINAL EMULATORS ###
  ##########################

  ####################
  ### CODE EDITORS ###
  ####################

  rstudio = {
    home.packages = [
      (pkgs.rstudioWrapper.override {
        packages = with pkgs.rPackages; [
          # ggplot2
          # dplyr
          # xts
          tinytex
          latexpdf
          # knitLatex
          quarto
          pkgs.texlive.combined.scheme-tetex
        ];
      })
      pkgs.pandoc
    ];
  };

  neovim = {
    programs.neovim.enable = true;
    home.packages = [ pkgs.neovide ];
  };
  helix = { programs.helix.enable = true; };
  lapce = { home.packages = [ pkgs.lapce ]; };

  #########################
  ### DEVELOPMENT TOOLS ###
  #########################

  git = {
    programs.git = {
      enable = true;
      package = pkgs.git.override {
        withLibsecret = true;
        # withSvnSupport = true;
      };

      userName = "Jacob Birkett";
      userEmail = "jacob@birkett.dev";

      extraConfig = {
        credential.helper =
          "${config.programs.git.package}/bin/git-credential-libsecret";
      };

      # better looking diffs
      delta.enable = true;
      delta.options = {
        syntax-theme = "Monokai Extended Bright";
        line-numbers = true;
        diff-so-fancy = true;
        grep-output-style = "ripgrep";
        hunk-header-decoration-style = "omit";
        hunk-header-style = "file line-number";
        hunk-header-file-style = "magenta";
        hunk-header-line-number-style = "yellow";
        line-numbers-minus-style = "bold red";
        line-numbers-plus-style = "bold green";
      };
    };
  };

  java = let
    # IntelliJ likes to see a `~/.jdks` directory,
    # so we will use that convention for now.
    homeJdksDir = ".jdks";
    defaultJdk = pkgs.temurin-bin;
  in {
    home.sessionPath =
      [ "${config.home.homeDirectory}/${homeJdksDir}/${defaultJdk.name}/bin" ];
    # Notice below, that each JDK source *is* the `home` of that JDK.
    home.sessionVariables.JAVA_HOME =
      "${config.home.homeDirectory}/${homeJdksDir}/${defaultJdk.name}";

    home.file = builtins.listToAttrs (map (package: {
      name = "${homeJdksDir}/${package.name}";
      # I think this should work because binaries are ELF-patched.
      value = { source = "${package.home}"; };
    }) [
      defaultJdk
      pkgs.jdk8
      pkgs.jdk11
      pkgs.jdk17
      pkgs.jdk # latest
      pkgs.temurin-bin-8
      pkgs.temurin-bin-11
      pkgs.temurin-bin-16
      pkgs.temurin-bin-17
      pkgs.temurin-bin-18
      pkgs.temurin-bin # latest
    ]);
  };

  rust = {
    home.file.".cargo/config.toml".source =
      (pkgs.formats.toml { }).generate "cargo-config" {
        "target.x86_64-unknown-linux-gnu" = {
          linker = lib.getExe pkgs.clang;
          rustFlags =
            [ "-C" "link-arg=--ld-path=${lib.makeBinPath [ pkgs.mold ]}" ];
        };
      };
  };

  ##########################
  ### SHELL ENVIRONMENTS ###
  ##########################

  bash = {
    home.packages = [ pkgs.blesh ];
    programs.bash = {
      enable = true;
      bashrcExtra = "source '${pkgs.blesh}/share/ble.sh'";
      historyIgnore = [ "reboot" "exit" ];
    };
    programs.starship.enableBashIntegration = true;
  };
  zsh = {
    imports = [ ./zsh.nix ];
    programs.zsh.alt.enable = true;
  };
  nushell = { programs.nushell.enable = true; };

  #####################
  ### CLI UTILITIES ###
  #####################

  bat = {
    programs.bat.enable = true;
    programs.bat.config.theme = "gruvbox-dark";
  };
  lsd = { programs.lsd.enable = true; };
  fzf = { programs.fzf.enable = true; };
  jq = { programs.jq.enable = true; };
  gallery-dl = { home.packages = [ pkgs.gallery-dl ]; };

  ###########################################
  ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
  ###########################################

  anydesk = { home.packages = [ pkgs.anydesk ]; };
  rustdesk = { home.packages = [ pkgs.rustdesk ]; };
  neofetch = { home.packages = [ pkgs.neofetch ]; };
  nix-index = { programs.nix-index.enable = true; };
  virt-manager = { home.packages = [ pkgs.virt-manager ]; };

  ###################
  ### VIDEO GAMES ###
  ###################

  ######################
  ### AUTHENTICATION ###
  ######################

  keepassxc = {
    home.packages = [
      (pkgs.symlinkJoin {
        inherit (pkgs.keepassxc) name;
        paths = [ pkgs.keepassxc ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/keepassxc \
            --set QT_QPA_PLATFORMTHEME ""
        '';
      })
    ];
  };

  ####################
  ### FILE SHARING ###
  ####################

  transmission = { home.packages = [ pkgs.transmission-qt ]; };
  qbittorrent = { home.packages = [ pkgs.qbittorrent ]; };
  filezilla = { home.packages = [ pkgs.filezilla ]; };

  ###################
  ### 3D PRINTING ###
  ###################

  openscad = { home.packages = [ pkgs.openscad ]; };
  prusa-slicer = { home.packages = [ pkgs.prusa-slicer ]; };
  super-slicer = { home.packages = [ pkgs.super-slicer-latest ]; };
  cura = { home.packages = [ pkgs.cura ]; };

  ################
  ### HARDWARE ###
  ################

  hardware.razer = { home.packages = [ pkgs.polychromatic ]; };
}
