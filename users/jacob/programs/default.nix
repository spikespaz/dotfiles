{
  config,
  lib,
  pkgs,
  nixpkgs,
  hmModules,
  ...
}: {
  ####################
  ### WEB BROWSERS ###
  ####################

  firefox = {
    programs.firefox.enable = true;
    # programs.firefox.package = pkgs.firefox-devedition-bin;
    imports = [./firefox];
  };
  chromium = {
    programs.chromium.enable = true;
  };

  #################################
  ### COMMUNICATION & MESSAGING ###
  #################################

  mailspring = {
    home.packages = [pkgs.mailspring];
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
    imports = [hmModules.webcord];

    programs.webcord = {
      enable = true;
      themes = let
        repo = pkgs.fetchFromGitHub {
          owner = "mwittrien";
          repo = "BetterDiscordAddons";
          rev = "8627bb7f71c296d9e05d82538d3af8f739f131dc";
          sha256 = "sha256-Dn6igqL0GvaOcTFZOtQOxuk0ikrWxyDZ41tNsJXJAxc=";
        };
      in {
        DiscordRecolor = "${repo}/Themes/DiscordRecolor/DiscordRecolor.theme.css";
        SettingsModal = "${repo}/Themes/SettingsModal/SettingsModal.theme.css";
      };
    };
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
    home.packages = [pkgs.slurp];
  };

  tools.video-editing = {
    home.packages = with pkgs; [
      libsForQt5.kdenlive
      handbrake
    ];
  };

  #########################
  ### MEDIA CONSUMPTION ###
  #########################

  spotify = {
    imports = [./spotify.nix];
  };

  #################################
  ### OFFICE & WRITING SOFTWARE ###
  #################################

  onlyoffice = {
    home.packages = [pkgs.onlyoffice-bin];
  };
  apostrophe = {
    home.packages = [pkgs.apostrophe];
  };

  ##########################
  ### TERMINAL EMULATORS ###
  ##########################

  alacritty = {
    programs.alacritty.enable = true;
    imports = [./alacritty.nix];
  };

  ####################
  ### CODE EDITORS ###
  ####################

  vscode = import ./vscode;
  neovim = {
    programs.neovim.enable = true;
    home.packages = [pkgs.neovide];
  };
  helix = {
    programs.helix.enable = true;
  };
  lapce = {
    home.packages = [pkgs.lapce];
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
    home.packages = [pkgs.blesh pkgs.wl-clipboard];
    programs.bash = {
      enable = true;
      bashrcExtra = "source '${pkgs.blesh}/share/ble.sh'";
      historyIgnore = ["reboot" "exit"];
    };
  };
  zsh = {
    imports = [./zsh.nix];
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
    home.packages = [pkgs.gallery-dl];
  };

  ###########################################
  ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
  ###########################################

  neofetch = {
    home.packages = [pkgs.neofetch];
  };
  wev = {
    home.packages = [pkgs.wev];
  };
  nix-index = {
    programs.nix-index.enable = true;
  };

  ######################
  ### AUTHENTICATION ###
  ######################

  keepassxc = {
    home.packages = [pkgs.keepassxc];
  };
}
