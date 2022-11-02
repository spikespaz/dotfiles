{
  ####################
  ### WEB BROWSERS ###
  ####################

  chromium = _: {
    programs.chromium.enable = true;
  };

  #################################
  ### COMMUNICATION & MESSAGING ###
  #################################

  mailspring = {pkgs, ...}: {
    home.packages = [pkgs.mailspring];
  };
  discord = {pkgs, ...}: {
    home.packages = [
      (pkgs.discord.override {
        # <https://github.com/GooseMod/OpenAsar>
        withOpenASAR = true;
        # fix for not respecting system browser
        nss = pkgs.nss_latest;
      })
    ];
  };
  webcord = {pkgs, hmModules, ...}: {
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

  hexchat = _: {
    programs.hexchat.enable = true;
  };

  ######################
  ### MEDIA CREATION ###
  ######################

  obs-studio = {pkgs, ...}: {
    programs.obs-studio.enable = true;
    programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-move-transition
    ];
    # needed for screen selection on wayland
    home.packages = [pkgs.slurp];
  };

  tools.video-editing = {pkgs, ...}: {
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

  onlyoffice = {pkgs, ...}: {
    home.packages = [pkgs.onlyoffice-bin];
  };
  apostrophe = {pkgs, ...}: {
    home.packages = [pkgs.apostrophe];
  };

  ##########################
  ### TERMINAL EMULATORS ###
  ##########################

  ####################
  ### CODE EDITORS ###
  ####################

  neovim = {pkgs, ...}: {
    programs.neovim.enable = true;
    home.packages = [pkgs.neovide];
  };
  helix = _: {
    programs.helix.enable = true;
  };
  lapce = {pkgs, ...}: {
    home.packages = [pkgs.lapce];
  };

  #########################
  ### DEVELOPMENT TOOLS ###
  #########################

  git = {pkgs, ...}: let
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

  bash = {pkgs, ...}: {
    home.packages = [pkgs.blesh];
    programs.bash = {
      enable = true;
      bashrcExtra = "source '${pkgs.blesh}/share/ble.sh'";
      historyIgnore = ["reboot" "exit"];
    };
    programs.starship.enableBashIntegration = true;
  };
  zsh = _: {
    imports = [./zsh.nix];
    programs.zsh-uncruft.enable = true;
  };

  #####################
  ### CLI UTILITIES ###
  #####################

  bat = _: {
    programs.bat.enable = true;
    programs.bat.config.theme = "gruvbox-dark";
  };
  lsd = _: {
    programs.lsd.enable = true;
  };
  fzf = _: {
    programs.fzf.enable = true;
  };
  gallery-dl = {pkgs, ...}: {
    home.packages = [pkgs.gallery-dl];
  };

  ###########################################
  ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
  ###########################################

  neofetch = {pkgs, ...}: {
    home.packages = [pkgs.neofetch];
  };
  wev = {pkgs, ...}: {
    home.packages = [pkgs.wev];
  };
  nix-index = _: {
    programs.nix-index.enable = true;
  };

  ###################
  ### VIDEO GAMES ###
  ###################

  ######################
  ### AUTHENTICATION ###
  ######################

  keepassxc = _: {pkgs, ...}: {
    home.packages = [pkgs.keepassxc];
  };
}
