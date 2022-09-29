{ config, lib, pkgs, nixpkgs, ... }: {
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
      # <https://hg.sr.ht/~scoopta/wlrobs>
      (wlrobs.overrideAttrs (old: {
        version = "unstable-2022-05-15";
        src = old.src.overrideAttrs (old: old // {
          rev = "3eb154e5fe639acb1b6be7041f5d5a62f7e723dc";
          sha256 = "";
        });
      }))
      # <https://github.com/exeldro/obs-move-transition>
      (obs-move-transition.overrideAttrs (old: rec {
        version = "2.6.1";
        src = old.src.overrideAttrs (old: old // {
          rev = version;
          sha256 = "sha256-zzZzG9wws4iGML+qfUNgXaRN5ODOiX0T0sfq/phObQI=";
        });
      }))
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
    # home.packages = [
    #   (pkgs.lapce.overrideAttrs (old: rec {
    #     version = "0.2.0";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "lapce";
    #       repo = "lapce";
    #       rev = "v${version}";
    #       sha256 = "sha256-cCcI5V6CMLkJM0miLv/o7LAJedrgb+z2CtWmF5/dmvY=";
    #     };
    #     # cannot set cargoSha256 because the output is transformed before
    #     # it is overrideable, this is the way since
    #     # rustPlatform.fetchCargoTarball is lib.mkOverrideable
    #     cargoDeps = old.cargoDeps.overrideAttrs (_: {
    #       inherit src;
    #       name = "${old.pname}-${version}-vendor.tar.gz";
    #       outputHash = "sha256-H8vPBXJ0tom07wjzi18oIYNUhZXraD74DF7+xn8hfrQ=";
    #     });
    #   }))
    # ];
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
