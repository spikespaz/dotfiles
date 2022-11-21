{
  lib,
  pkgs,
  ...
}: let
  # things to do for every user
  prefab = {
    settings = {
      "trailhead.firstrun.didSeeAboutWelcome" = true;
    };
  };
  # set up for userChrome.css
  userChrome = {
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "browser.uidensity" = 1;
      "ui.prefersReducedMotion" = 1;
      "layout.css.has-selector.enabled" = true;
      "signon.rememberSignons" = false;
    };
    userChrome = builtins.readFile ./userChrome.css;
  };
in {
  programs.firefox.enable = true;

  imports = [
    ./hosts.nix
  ];

  programs.firefox.profiles = {
    "jacob.default" = lib.mkMerge [
      prefab
      userChrome
      {
        id = 0;
        isDefault = true;
        name = "jacob-default";
        settings = {
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
        };
      }
    ];
  };

  programs.firefox.extensions = let
    rycee = pkgs.nur.repos.rycee.firefox-addons;
    bandithedoge = pkgs.nur.repos.bandithedoge.firefoxAddons;
  in [
    ### BASICS ###
    rycee.darkreader
    rycee.tree-style-tab

    ### PERFORMANCE ###
    rycee.h264ify
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
    bandithedoge.gitako
    # rycee.enhanced-github
    # rycee.refined-github
    # rycee.lovely-forks
    # rycee.octolinker
    # rycee.octotree

    ### YOUTUBE ###
    rycee.sponsorblock
    rycee.return-youtube-dislikes
    # rycee.enhancer-for-youtube

    ### NEW INTERNET ###
    # rycee.ipfs-companion

    ### FIXES ###
    rycee.open-in-browser
    # rycee.no-pdf-download
    # rycee.don-t-fuck-with-paste

    ### UTILITIES ###
    # rycee.export-tabs-urls-and-titles
    # rycee.markdownload
    # rycee.flagfox
    rycee.keepassxc-browser
  ];
}
