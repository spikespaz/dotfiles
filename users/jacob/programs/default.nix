{ pkgs, nixpkgs, inputs, ... }: {
  ####################
  ### WEB BROWSERS ###
  ####################

  firefox = {
    programs.firefox.enable = true;
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
    home.packages = [ pkgs.discord ];
    nixpkgs.overlays = let
      discordOverlay = self: super: {
        discord = super.discord.override {
          # <https://github.com/GooseMod/OpenAsar>
          withOpenASAR = true;
          # fix for not respecting system browser
          nss = pkgs.nss_latest;
        };
      };
    in [
      discordOverlay
    ];
  };
  webcord = {
    home.packages = [ inputs.webcord.packages.${pkgs.system}.default ];
  };
  neochat = {
    home.packages = [ pkgs.neochat ];
  };
  hexchat = {
    programs.hexchat.enable = true;
  };

  ######################
  ### MEDIA CREATION ###
  ######################

  obs-studio = {
    programs.obs-studio.enable = true;
    # needed for screen selection on wayland
    home.packages = [ pkgs.slurp ];
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
    programs.alacritty.settings = import ./alacritty.nix;
    home.packages = [
      (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  ####################
  ### CODE EDITORS ###
  ####################

  vscode = {
    programs.vscode.enable = true;
    imports = [ ./vscode.nix ];
  };
  neovim = {
    programs.neovim.enable = true;
    home.packages = [ pkgs.neovide ];
  };
  helix = {
    programs.helix.enable = true;
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
