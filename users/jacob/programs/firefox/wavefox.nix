profile:
{ pkgs, config, ... }:
let cfg = config.programs.firefox;
in {
  # <https://github.com/QNetITQ/WaveFox>
  home.file."${cfg.profilesPath}/${profile}/chrome".source = pkgs.wavefox;

  programs.firefox.profiles.${profile} = {
    # Must be set so that the individual entries are not created.
    userChrome = "";
    userContent = "";

    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      "gfx.webrender.all" = true;

      # Fix for the close button being inline wth tabs.
      # "browser.tabs.inTitlebar" = 1;
      # Also puts a close button in the title bar, which we want to hide.
      # This is required to be `1` for transparency.
      "browser.tabs.inTitlebar" = 0;
      "browser.tabs.tabMinWidth" = 130;

      # Selecting "Compact" in the toolbar customization menu sets both of these options.
      "browser.uidensity" = 1;
      "browser.compactmode.show" = true;

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
      "WaveFox.Icons" = 2;
      # Lepton icons everywhere
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
    };
  };
}
