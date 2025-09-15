{ pkgs, ... }:
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
  ];

  home.packages = [ pkgs.firefoxpwa ];
  programs.firefox.nativeMessagingHosts = [ pkgs.firefoxpwa ];

  programs.firefox.profiles.${profile} = {
    id = 0;
    isDefault = true;
    name = profileName;

    # <https://github.com/QNetITQ/WaveFox>
    # userChrome = pkgs.wavefox;

    search.default = "ddg";

    settings = {
      # Do not require manual intervention to enable extensions.
      # This might be a security hole.
      "extensions.autoDisableScopes" = 0;

      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      "gfx.webrender.all" = true;

      # Fix for the close button being inline wth tabs.
      # "browser.tabs.inTitlebar" = 1;
      # Also puts a close button in the title bar, which we want to hide.
      # This is required to be `1` for transparency.
      "browser.tabs.inTitlebar" = 0;
      "browser.tabs.tabMinWidth" = 130;

      # Selecting "Compact" in the toolbar customization menu sets both
      # of these options.
      "browser.uidensity" = 1;
      "browser.compactmode.show" = true;
      # "ui.prefersReducedMotion" = 1;

      "browser.download.autohideButton" = false;

      ### WaveFox ###

      "WaveFox.Tabs.Shape" = 7;
      "WaveFox.DarkTheme.Tabs.Shadows" = 2;
      "WaveFox.Tabs.Separators" = 1;

      # TODO: This doesn't look as good as I want unfortunately.
      # I want to have more granular transparency control
      # to match the values used in Hyprland window rules.
      # Makes the tab text hard to read and requires `browser.tabs.inTitlebar`.
      # "browser.tabs.inTitlebar" = 1;
      # "WaveFox.Linux.Transparency.Enabled" = true;
      # "WaveFox.Toolbar.Transparency" = 3;

      "svg.context-properties.content.enabled" = true;
      "WaveFox.LeptonIcons.Enabled" = true;
      # I think `panel_photon` and `panel_full` are mutually exclusive, not sure which to use.
      # In the hamburger menu, with both enabled, the zoom icon is offset to the left.
      # "userChrome.icon.panel_photon" = true;
      "userChrome.icon.panel_full" = true;
      "userChrome.icon.library" = true;
      "userChrome.icon.panel" = true;
      "userChrome.icon.menu" = true;
      "userChrome.icon.context_menu" = true;
      "userChrome.icon.global_menu" = true;
      "userChrome.icon.global_menubar" = true;
      "userChrome.icon.1-25px_stroke" = true;
      "userChrome.icon.account_image_to_right" = true;
      "userChrome.icon.account_label_to_right" = true;
      "userChrome.icon.menu.full" = true;
      "userChrome.icon.global_menu.mac" = true;

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
