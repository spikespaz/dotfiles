{
  config,
  lib,
  pkgs,
  nixpkgs,
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
  webcord = let
    catppuccin = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "discord";
      rev = "159aac939d8c18da2e184c6581f5e13896e11697";
      sha256 = "sha256-cWpog52Ft4hqGh8sMWhiLUQp/XXipOPnSTG6LwUAGGA=";
    };
    theme = "${catppuccin}/themes/macchiato.theme.css";
  in {
    home.packages = [
      (pkgs.webcord.override {
        flags = "--add-css-theme=${theme}";
      })
    ];
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

  tools.encoding = {
    home.packages = [pkgs.handbrake];
  };

  #########################
  ### MEDIA CONSUMPTION ###
  #########################

  spotify = {
    home.packages = [pkgs.spotify];
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
}
