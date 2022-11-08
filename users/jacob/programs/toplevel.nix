{pkgs, ...}: {
  ####################
  ### WEB BROWSERS ###
  ####################

  chromium = {
    programs.chromium.enable = true;
  };

  #################################
  ### COMMUNICATION & MESSAGING ###
  #################################

  mailspring = {
    home.packages = [pkgs.mailspring];
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

  ####################
  ### CODE EDITORS ###
  ####################

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

  git = let
    package =
      (pkgs.git.override {
        withLibsecret = true;
        # withSvnSupport = true;
      })
      .overrideAttrs (old: {
        # not sure why this is failing
        # <https://github.com/NixOS/nixpkgs/issues/195891>
        doInstallCheck = false;
      });
  in {
    programs.git = {
      enable = true;
      package = package;

      userName = "Jacob Birkett";
      userEmail = "jacob@birkett.dev";

      extraConfig = {
        credential.helper = "${package}/bin/git-credential-libsecret";
      };

      # better looking diffs
      delta.enable = true;
    };
  };

  ##########################
  ### SHELL ENVIRONMENTS ###
  ##########################

  bash = {
    home.packages = [pkgs.blesh];
    programs.bash = {
      enable = true;
      bashrcExtra = "source '${pkgs.blesh}/share/ble.sh'";
      historyIgnore = ["reboot" "exit"];
    };
    programs.starship.enableBashIntegration = true;
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
  nix-index = {
    programs.nix-index.enable = true;
  };

  ###################
  ### VIDEO GAMES ###
  ###################

  ######################
  ### AUTHENTICATION ###
  ######################

  keepassxc = {
    home.packages = [pkgs.keepassxc];
  };

  ####################
  ### FILE SHARING ###
  ####################

  transmission = {
    home.packages = [pkgs.transmission-qt];
  };
}
