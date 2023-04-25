{ ... }: {
  userConfig = {
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "browser.uidensity" = 1;
    "ui.prefersReducedMotion" = 1;
    "layout.css.has-selector.enabled" = true;
    "tabMinWidth" = 130;
  };

  sources = { "./" = ./.; };

  blacklistGlobs = [ "default.nix" "chrome.nix" ];
}
