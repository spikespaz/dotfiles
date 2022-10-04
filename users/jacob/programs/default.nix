{ config, lib, pkgs, nixpkgs, ... }: {
  ####################
  ### WEB BROWSERS ###
  ####################

  firefox = {
    programs.firefox.enable = true;

    programs.firefox.extensions = let
      rycee = pkgs.nur.repos.rycee.firefox-addons;
      bandithedoge = pkgs.nur.repos.bandithedoge.firefoxAddons;
    in [
      ### BASICS ###
      rycee.darkreader
      rycee.tree-style-tab

      ### PERFORMANCE ###
      rycee.h264ify
      rycee.localcdn
      rycee.auto-tab-discard

      ### BLOCKING ###
      rycee.ublock-origin
      rycee.i-dont-care-about-cookies

      ### GITHUB ###
      bandithedoge.gitako
    ];

    programs.firefox.profiles = let
      prefab = {
        settings = {
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.uidensity" = 1;
          "ui.prefersReducedMotion" = 1;
        };
        userChrome = builtins.readFile ./userChrome.css;
      };
    in {
      "jacob.default" = lib.recursiveUpdate prefab {
        id = 0;
        isDefault = true;
        name = "Jacob Default";
      };
    };
  };
  chromium = {
    programs.chromium.enable = true;
  };

  #################################
  ### COMMUNICATION & MESSAGING ###
  #################################

  mailspring = {
    home.packages = [ pkgs.mailspring ];
  };
  discord = {
    home.packages = [
      (pkgs.discord.override {
        # <https://github.com/GooseMod/OpenAsar>
        withOpenASAR = true;
        # fix for not respecting system browser
        nss = pkgs.nss_latest;
      })
    ];
  };
  webcord = {
    home.packages = [ pkgs.webcord ];
  };
  hexchat = {
    programs.hexchat.enable = true;
  };

  ######################
  ### MEDIA CREATION ###
  ######################

  obs-studio = {
    programs.obs-studio.enable = true;
    programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-move-transition
    ];
    # needed for screen selection on wayland
    home.packages = [ pkgs.slurp ];
  };

  #########################
  ### MEDIA CONSUMPTION ###
  #########################

  spotify = {
    home.packages = [ pkgs.spotify ];
  };

  #################################
  ### OFFICE & WRITING SOFTWARE ###
  #################################

  onlyoffice = {
    home.packages = [ pkgs.onlyoffice-bin ];
  };
  apostrophe = {
    home.packages = [ pkgs.apostrophe ];
  };

  ##########################
  ### TERMINAL EMULATORS ###
  ##########################

  alacritty = {
    programs.alacritty.enable = true;
    imports = [ ./alacritty.nix ];
  };

  ####################
  ### CODE EDITORS ###
  ####################

  vscode = import ./vscode;
  neovim = {
    programs.neovim.enable = true;
    home.packages = [ pkgs.neovide ];
  };
  helix = {
    programs.helix.enable = true;
  };
  lapce = {
    home.packages = [ pkgs.lapce ];
  };

  #########################
  ### DEVELOPMENT TOOLS ###
  #########################

  git = {
    programs.git.enable = true;
    programs.git = {
      userName = "Jacob Birkett";
      userEmail = "jacob@birkett.dev";

      # better looking diffs
      delta.enable = true;
    };
  };

  ##########################
  ### SHELL ENVIRONMENTS ###
  ##########################

  bash = {
    home.packages = [ pkgs.blesh pkgs.wl-clipboard ];
    programs.bash = {
      enable = true;
      bashrcExtra = "source '${pkgs.blesh}/share/ble.sh'";
      historyIgnore = [ "reboot" "exit" ];
    };
  };
  zsh = {
    imports = [ ./zsh.nix ];
    programs.zsh-uncruft.enable = true;
  };

  #####################
  ### CLI UTILITIES ###
  #####################

  bat = {
    programs.bat.enable = true;
    programs.bat.config.theme = "gruvbox-dark";
  };
  lsd = {
    programs.lsd.enable = true;
  };
  fzf = {
    programs.fzf.enable = true;
  };
  gallery-dl = {
    home.packages = [ pkgs.gallery-dl ];
  };

  ###########################################
  ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
  ###########################################

  neofetch = {
    home.packages = [ pkgs.neofetch ];
  };
  wev = {
    home.packages = [ pkgs.wev ];
  };
  nix-index = {
    programs.nix-index.enable = true;
  };
}
