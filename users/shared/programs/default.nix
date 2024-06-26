args@{ self, lib, pkgs, pkgs-stable, config, inputs, ... }:
(lib.mapAttrs (_: expr: if lib.isFunction expr then expr args else expr)
  (lib.importDir' ./. "default.nix")) // {
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

    ##################################
    ### DOCUMENT/FILETYPE HANDLERS ###
    ##################################

    zathura = {
      programs.zathura.enable = true;
      programs.zathura.options = {
        # Show statusbar, horizontal and vertical scrollbar
        guioptions = "shv";
        # Full features, printing is enabled, light security.
        sandbox = "normal";
        # Default to dark theme.
        recolor = true;
        # When selecting text, copy to the system clipboard
        selection-clipboard = "clipboard";
        # Odd-numbered pages on the left
        first-page-column = "1:1";
        # Use the basename of the file for the window title
        window-title-basename = true;
        # Gruvbox foreground on dark mode
        recolor-darkcolor = lib.birdos.colors.formats.hexRGB'.gruvbox.dark.fg1;
      };
      programs.zathura.mappings = {
        "<C-=>" = "zoom in";
        "<C-->" = "zoom out";
      };
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

    mattermost = { home.packages = [ pkgs.mattermost-desktop ]; };

    ######################
    ### MEDIA CREATION ###
    ######################

    ## VIDEO ##

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
    handbrake = {
      # Since the Handbrake package has a habit of breaking (ffmpeg), use the version from Nixpkgs stable.
      home.packages = [ pkgs-stable.handbrake ];
    };
    ffmpeg = { home.packages = [ pkgs.ffmpeg ]; };
    kdenlive = { home.packages = [ pkgs.libsForQt5.kdenlive ]; };
    shotcut = { home.packages = [ pkgs.shotcut ]; };

    ## IMAGE ##

    pinta = { home.packages = [ pkgs.pinta ]; };
    gimp = { home.packages = [ pkgs.gimp ]; };

    #########################
    ### MEDIA CONSUMPTION ###
    #########################

    tidal = { home.packages = [ pkgs.tidal-hifi ]; };

    #################################
    ### OFFICE & WRITING SOFTWARE ###
    #################################

    onlyoffice = {
      home.packages = [ pkgs.onlyoffice-bin_latest ];
      xdg.configFile."onlyoffice/DesktopEditors.conf".text =
        lib.generators.toINI { } {
          General = {
            UITheme2 = "theme-dark";
            appdata =
              "@ByteArray(eyJ1c2VybmFtZSI6ImphY29iIiwiZG9jb3Blbm1vZGUiOiJlZGl0IiwibGFuZ2lkIjoiZW4tRU4iLCJ1aXNjYWxpbmciOiIxNTAiLCJ1aXRoZW1lIjoidGhlbWUtZGFyayIsImVkaXRvcndpbmRvd21vZGUiOmZhbHNlfQ==)";
            editorWindowMode = false;
            openPath = "/home/jacob/Downloads";
            position = "Rect(1450 61 1411 1720)";
            savePath = "/home/jacob/Desktop";
            titlebar = "system";
          };
        };
    };
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
          alias.c-m = "commit -m";
          alias.undo = "reset --soft HEAD~1";
          alias.am = "commit --amend --no-edit";
          alias.cl = "clone";
          alias.sw = "switch";
          alias.ic = "commit -m 'initial commit' --allow-empty";
          alias.rsu = "remote set-url";

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

    nix = {
      # TODO fix overlay for this flake
      home.packages = with pkgs; [ nixfmt-classic json2nix ];
    };

    java = let
      # IntelliJ likes to see a `~/.jdks` directory,
      # so we will use that convention for now.
      homeJdksDir = ".jdks";
      defaultJdk = pkgs.temurin-bin;
    in {
      home.sessionPath = [
        "${config.home.homeDirectory}/${homeJdksDir}/${defaultJdk.name}/bin"
      ];
      # Notice below, that each JDK source *is* the `home` of that JDK.
      home.sessionVariables.JAVA_HOME =
        "${config.home.homeDirectory}/${homeJdksDir}/${defaultJdk.name}";

      home.file = builtins.listToAttrs (map (package: {
        name = "${homeJdksDir}/${package.name}";
        # I think this should work because binaries are ELF-patched.
        value = { source = "${package.home}"; };
      }) (with pkgs; [
        defaultJdk
        jdk8
        jdk11
        jdk17
        jdk # latest
        temurin-bin-8
        temurin-bin-11
        temurin-bin-16
        temurin-bin-17
        temurin-bin-18
        temurin-bin # latest
      ]));
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

    remmina = { home.packages = [ pkgs.remmina ]; };
    anydesk = { home.packages = [ pkgs.anydesk ]; };
    rustdesk = { home.packages = [ pkgs.rustdesk ]; };
    neofetch = { home.packages = [ pkgs.neofetch ]; };
    nix-index = { programs.nix-index.enable = true; };
    virt-manager = { home.packages = [ pkgs.virt-manager ]; };

    ###################
    ### VIDEO GAMES ###
    ###################

    moonlight = {
      home.packages = [
        (pkgs.moonlight-qt.overrideAttrs (self: super: {
          buildInputs = super.buildInputs ++ [ pkgs.libva1 ];
        }))
      ];
    };
    steam = {
      imports = [ self.homeManagerModules.steam ];
      home.packages = [ pkgs.steam-tui pkgs.gamescope ];
      programs.steam.protonGE.versions = {
        "7-55" = "sha256-6CL+9X4HBNoB/yUMIjA933XlSjE6eJC86RmwiJD6+Ws=";
        "8-25" = "sha256-IoClZ6hl2lsz9OGfFgnz7vEAGlSY2+1K2lDEEsJQOfU=";
      };
    };
    prism-launcher = let
      # Pre-launch command
      #   test -f '$INST_MC_DIR/options.txt' && sed -i 's/fullscreen:true/fullscreen:false/' '$INST_MC_DIR/options.txt' || exit 0
      # Wrapper command
      #   export force_glsl_extensions_warn=true
      #   run-game "$@"
      prismlauncher' = pkgs.prismlauncher.override {
        withWaylandGLFW = true;
        jdks = with pkgs; [
          # Java 8
          temurin-jre-bin-8
          zulu8
          graalvm8-ce-jre
          # Java 11
          temurin-jre-bin-11
          # Java 20
          temurin20-jre-bin
          # Latest
          temurin-jre-bin
          zulu
          graalvm-ce
        ];
      };
    in { home.packages = [ prismlauncher' ]; };

    ######################
    ### AUTHENTICATION ###
    ######################

    keepassxc = {
      imports = [ self.homeManagerModules.keepassxc ];

      programs.keepassxc = {
        enable = true;

        # KeePassXC doesn't play nice with
        # custom Qt themes, and default looks great.
        package = (pkgs.symlinkJoin {
          inherit (pkgs.keepassxc) name pname version meta;
          paths = [ pkgs.keepassxc ];
          nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
          postBuild = ''
            wrapProgram $out/bin/keepassxc \
              --set QT_QPA_PLATFORMTHEME ""
          '';
        });

        settings = {
          General = {
            ConfigVersion = 2;
            UseAtomicSaves = true;
          };
          Browser = {
            Enabled = true;
            SearchInAllDatabases = true;
          };
          FdoSecrets = { Enabled = true; };
          GUI = {
            ApplicationTheme = "dark";
            ColorPasswords = true;
            MinimizeOnClose = true;
            MinimizeOnStartup = true;
            MinimizeToTray = true;
            MonospaceNotes = true;
            ShowTrayIcon = true;
            TrayIconAppearance = "monochrome-light";
          };
          PasswordGenerator = {
            AdditionalChars = "";
            ExcludedChars = "";
            Length = 22;
          };
          Security = let minutes = s: builtins.floor (s * 60);
          in {
            ClearClipboardTimeout = minutes 0.75;
            EnableCopyOnDoubleClick = true;
            IconDownloadFallback = true;
            LockDatabaseIdle = true;
            LockDatabaseIdleSeconds = minutes 10;
          };
        };

        browserIntegration.firefox = true;
      };
    };

    ####################
    ### FILE SHARING ###
    ####################

    transmission = { home.packages = [ pkgs.transmission-qt ]; };
    qbittorrent = { home.packages = [ pkgs.qbittorrent ]; };
    filezilla = { home.packages = [ pkgs.filezilla ]; };
    jellyfin = { home.packages = [ pkgs.jellyfin ]; };

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
