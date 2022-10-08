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
    };
    userChrome = builtins.readFile ./userChrome.css;
  };
in {
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

    ### GITHUB ###
    bandithedoge.gitako
  ];
}
