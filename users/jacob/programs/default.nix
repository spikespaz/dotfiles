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
      # Enable "Annoyances" lists in uBO instead
      # rycee.i-dont-care-about-cookies

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
    # <https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin>
    home.file.".mozilla/managed-storage/uBlock0@raymondhill.net.json".text = builtins.toJSON {
      name = "uBlock0@raymondhill.net";
      description = "ignored";
      type = "storage";
      data = let
        stevenBlackHosts = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        defaultFilteringString = ''
          behind-the-scene * * noop
          behind-the-scene * 1p-script noop
          behind-the-scene * 3p noop
          behind-the-scene * 3p-frame noop
          behind-the-scene * 3p-script noop
          behind-the-scene * image noop
          behind-the-scene * inline-script noop
        '';
      in {
        adminSettings = builtins.toJSON {
          userSettings = {
            advancedUserEnabled = true;
            dynamicFilteringEnabled = true;
            externalLists = lib.concatStringsSep "\n" [
              stevenBlackHosts
            ];
            importedLists = [
              stevenBlackHosts
            ];
          };
          selectedFilterLists = [
            # Built-in
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-abuse"
            "ublock-unbreak"
            # Ads
            "easylist"
            # Privacy
            "adguard-spyware"
            "adguard-spyware-url"
            "easyprivacy"
            # Malware domains
            "urlhaus-1"
            "curben-phishing"
            "curben-pup"
            # Annoyances
            "adguard-annoyance"
            "adguard-social"
            "fanboy-thirdparty_social"
            "fanboy-cookiemonster"
            "fanboy-annoyance"
            "fanboy-social"
            "ublock-annoyances"
            # Multipurpose
            "dpollock-0"
            "plowe-0"
            # Custom
            stevenBlackHosts
          ];
          # <https://codeberg.org/nobody/LocalCDN/wiki#user-content-6-why-do-i-need-this-rule-generator-i-use-an-adblocker-and-want-to-import-these-rules-how-does-it-work>
          dynamicFilteringString = ''
            ${defaultFilteringString}
            * ajax.googleapis.com * noop
            * ajax.aspnetcdn.com * noop
            * ajax.microsoft.com * noop
            * cdnjs.cloudflare.com * noop
            * code.jquery.com * noop
            * cdn.jsdelivr.net * noop
            * fonts.googleapis.com * noop
            * yastatic.net * noop
            * yandex.st * noop
            * apps.bdimg.com * noop
            * libs.baidu.com * noop
            * cdn.staticfile.org * noop
            * cdn.bootcss.com * noop
            * mat1.gtimg.com * noop
            * lib.sinaapp.com * noop
            * upcdn.b0.upaiyun.com * noop
            * stackpath.bootstrapcdn.com * noop
            * maxcdn.bootstrapcdn.com * noop
            * netdna.bootstrapcdn.com * noop
            * use.fontawesome.com * noop
            * ajax.cloudflare.com * noop
            * akamai-webcdn.kgstatic.net * noop
            * gitcdn.github.io * noop
            * vjs.zencdn.net * noop
            * cdn.plyr.io * noop
            * cdn.materialdesignicons.com * noop
            * cdn.ravenjs.com * noop
            * js.appboycdn.com * noop
            * cdn.embed.ly * noop
            * cdn.datatables.net * noop
            * mathjax.rstudio.com * noop
            * cdn.mathjax.org * noop
            * code.createjs.com * noop
            * sdn.geekzu.org * noop
            * ajax.proxy.ustclug.org * noop
            * unpkg.com * noop
            * pagecdn.io * noop
            * cdnjs.loli.net * noop
            * ajax.loli.net * noop
            * fonts.loli.net * noop
            * lib.baomitu.com * noop
            * cdn.bootcdn.net * noop
            * fonts.gstatic.com * noop
            * ajax.loli.net.cdn.cloudflare.net * noop
            * akamai-webcdn.kgstatic.net.edgesuite.net * noop
            * apps.bdimg.jomodns.com * noop
            * cdn.bootcdn.net.maoyundns.com * noop
            * cdn.bootcss.com.maoyundns.com * noop
            * cdn.embed.ly.cdn.cloudflare.net * noop
            * cdn.jsdelivr.net.cdn.cloudflare.net * noop
            * cdnjs.loli.net.cdn.cloudflare.net * noop
            * cds.s5x3j6q5.hwcdn.net * noop
            * developer.n.shifen.com * noop
            * dualstack.osff.map.fastly.net * noop
            * fonts.loli.net.cdn.cloudflare.net * noop
            * gateway.cname.ustclug.org * noop
            * gstaticadssl.l.google.com * noop
            * iduwdjf.qiniudns.com * noop
            * lb.sae.sina.com.cn * noop
            * lib.baomitu.com.qh-cdn.com * noop
            * mat1.gtimg.com.tegsea.tc.qq.com * noop
            * materialdesignicons.b-cdn.net * noop
            * mscomajax.vo.msecnd.net * noop
            * sdn.inbond.gslb.geekzu.org * noop
            * use.fontawesome.com.cdn.cloudflare.net * noop
            * vo.aicdn.com * noop
          '';
        };
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
