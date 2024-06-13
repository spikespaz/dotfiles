{ self, lib, pkgs, config, ... }:
let
  profile = "jacob.default";
  profileName = "jacob-default";
in {
  programs.firefox.enable = true;

  imports = [
    ./ublock-origin.nix
    # self.homeManagerModules.firefox-pwa
    self.homeManagerModules.firefox-userchrome
  ];

  # programs.firefox.pwa.enable = true;

  programs.firefox.profiles.${profile} = lib.mkMerge [{
    id = 0;
    isDefault = true;
    name = profileName;

    settings = {
      # Allow firefox devtools to inspect the browser's UI chrome.
      "devtools.chrome.enabled" = true;
      # Enable remote (window) debugging. The chrome of another window included.
      "devtools.debugger.remote-enabled" = true;
      # Never, let the password manager do that.
      "signon.rememberSignons" = false;

      # "Open previous windows and tabs"
      "browser.startup.page" = 3;

      # Enable new WebRender everywhere.
      "gfx.webrender.all" = true;

      # Hide the crap on the New Tab page.
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;

      # Yes I have seen the welcome page many times
      "trailhead.firstrun.didSeeAboutWelcome" = true;
    };

    extensions = with {
      rycee = pkgs.nur.repos.rycee.firefox-addons;
      bandithedoge = pkgs.nur.repos.bandithedoge.firefoxAddons;
      slaier = pkgs.nur.repos.slaier.firefox-addons;
      spikespaz = pkgs.firefox-extensions;
    }; [
      ### BASICS ###
      rycee.darkreader
      # rycee.tree-style-tab
      rycee.tab-stash
      rycee.translate-web-pages

      ### PERFORMANCE ###
      rycee.auto-tab-discard
      rycee.localcdn

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
      spikespaz.twitch-auto-clicker
      # For Twitch, it is also worth considering removing the extension and just using uBO.
      # <https://github.com/pixeltris/TwitchAdSolutions>
      spikespaz.ttv-lol-pro
      spikespaz.frankerfacez

      ### NEW INTERNET ###
      # rycee.ipfs-companion

      ### FIXES ###
      # rycee.open-in-browser
      # rycee.no-pdf-download
      # rycee.don-t-fuck-with-paste

      ### UTILITIES ###
      rycee.video-downloadhelper
      # rycee.export-tabs-urls-and-titles
      # rycee.markdownload
      # rycee.flagfox
      rycee.keepassxc-browser
      rycee.wappalyzer
      # slaier.dictionary-anywhere
    ];
  }];

  # <https://github.com/QNetITQ/WaveFox>
  programs.firefox.userChrome.profiles."jacob.default" = {
    # recursive = true;
    source = pkgs.callPackage ./wavefox.nix { inherit lib; };

    extraSettings = {
      "browser.uidensity" = 1;
      # "ui.prefersReducedMotion" = 1;
      "browser.tabs.tabMinWidth" = 130;

      # Fix for the close button being inline wth tabs.
      "browser.tabs.inTitlebar" = 0;

      # WaveFox
      "svg.context-properties.content.enabled" = true;

      # slight rounding
      "userChrome.Tabs.Option8.Enabled" = true;

      # "browser.tabs.inTitlebar" = 1; # needed for transparency
      # "userChrome.Linux.Transparency.Low.Enabled" = true;
      "userChrome.DarkTheme.Tabs.Shadows.Saturation.Low.Enabled" = true;
      "userChrome.TabSeparators.Saturation.Medium.Enabled" = true;
      # "userChrome.Menu.Size.Compact.Enabled" = true;
    };
  };
}
