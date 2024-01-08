{ self, lib, pkgs, ... }:
let
  profile = "jacob.default";
  profileName = "jacob-default";

  # things to do for every user
  prefab = { settings = { "trailhead.firstrun.didSeeAboutWelcome" = true; }; };

  extensions = {
    rycee = pkgs.nur.repos.rycee.firefox-addons;
    bandithedoge = pkgs.nur.repos.bandithedoge.firefoxAddons;
    slaier = pkgs.nur.repos.slaier.firefox-addons;
    spikespaz = pkgs.callPackage ./extensions.nix { };
  };
in {
  programs.firefox.enable = true;

  imports = [
    ./blocking.nix
    # self.homeManagerModules.firefox-pwa
    self.homeManagerModules.firefox-userchrome
  ];

  # programs.firefox.pwa.enable = true;

  programs.firefox.userChrome.profiles.${profile} = {
    source = ./chrome;
    # recursive = true;
    extraSettings = { # settings specific to my theme
      "browser.uidensity" = 1;
      "ui.prefersReducedMotion" = 1;
      "browser.tabs.tabMinWidth" = 130;
    };
  };

  programs.firefox.profiles.${profile} = lib.mkMerge [
    prefab
    {
      id = 0;
      isDefault = true;
      name = profileName;

      settings = {
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = true;
        "signon.rememberSignons" = false;
        # "Open previous windows and tabs"
        "browser.startup.page" = 3;
      };

      extensions = with extensions; [
        ### BASICS ###
        rycee.darkreader
        # rycee.tree-style-tab
        rycee.tab-stash
        rycee.translate-web-pages

        ### PERFORMANCE ###
        rycee.auto-tab-discard

        ### BLOCKING ###
        # Enable "Annoyances" lists in uBO instead
        # rycee.i-dont-care-about-cookies
        rycee.user-agent-string-switcher
        # rycee.gaoptout
        # rycee.clearurls
        # rycee.disconnect
        # rycee.libredirect

        ### GITHUB ###
        # bandithedoge.gitako
        bandithedoge.sourcegraph
        # rycee.enhanced-github
        # rycee.refined-github
        rycee.lovely-forks
        # rycee.octolinker
        # rycee.octotree

        ### YOUTUBE ###
        rycee.sponsorblock
        rycee.return-youtube-dislikes
        # rycee.enhancer-for-youtube

        ### TWITCH ###
        spikespaz.twitchautoclicker

        ### NEW INTERNET ###
        # rycee.ipfs-companion

        ### FIXES ###
        # rycee.open-in-browser
        # rycee.no-pdf-download
        # rycee.don-t-fuck-with-paste

        ### UTILITIES ###
        # rycee.export-tabs-urls-and-titles
        # rycee.markdownload
        # rycee.flagfox
        rycee.keepassxc-browser
        rycee.wappalyzer
        # slaier.dictionary-anywhere
      ];
    }
  ];
}
