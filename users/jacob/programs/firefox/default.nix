{ lib, pkgs, ... }:
let
  profile = "jacob.default";
  profileName = "jacob-default";

  extensions = {
    rycee = pkgs.nur.repos.rycee.firefox-addons;
    bandithedoge = pkgs.nur.repos.bandithedoge.firefoxAddons;
    slaier = pkgs.nur.repos.slaier.firefox-addons;
    spikespaz = pkgs.firefox-extensions;
  };
in {
  programs.firefox.enable = true;

  imports = [ # #
    (import ./blocking.nix profile)
    (import ./wavefox.nix profile)
  ];

  home.packages = [ pkgs.firefoxpwa ];
  programs.firefox.nativeMessagingHosts = [ pkgs.firefoxpwa ];

  programs.firefox.profiles.${profile} = {
    id = 0;
    isDefault = true;
    name = profileName;

    # Clobber unconditionally, `./search-engines.nix` is source of truth.
    search.force = true;
    search.default = "ddg";
    search.engines = import ./search-engines.nix { inherit lib; };

    settings = {
      # Do not require manual intervention to enable extensions.
      # This might be a security hole.
      "extensions.autoDisableScopes" = 0;

      "browser.download.autohideButton" = false;

      # Restore previous windows and tabs
      "browser.startup.page" = 3;

      # No clickbait or trash on new-tab page.
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

      # No sponsored suggestions.
      "browser.urlbar.suggest.quicksuggest.sponsored" = false;

      # Allow playing DRM-controlled content.
      "media.eme.enabled" = true;

      # Tell websites not to sell or share my data.
      "privacy.globalprivacycontrol.enabled" = true;

      # Disable "Firefox Labs" because I'm afraid of it messing with extensions and user chrome.
      # Note that `enabled = false` is the correct value to disable, despite being named "opt-out".
      "app.shield.optoutstudies.enabled" = false;

      # <wiki.archlinux.org/title/Firefox#XDG_Desktop_Portal_integration>
      "widget.use-xdg-desktop-portal.file-picker" = 1;
      "widget.use-xdg-desktop-portal.mime-handler" = 1;
      "widget.use-xdg-desktop-portal.open-uri" = 1;
    };

    extensions.packages = with extensions; [
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
      spikespaz.pwas-for-firefox
    ];
  };
}
