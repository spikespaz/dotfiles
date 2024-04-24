{ pkgs, lib }: {
  # Clicks the stupid little green loot box for me.
  twitch-auto-clicker = let fileId = "3944212";
  in pkgs.buildFirefoxXpiAddon rec {
    pname = "twitchautoclicker";
    version = "0.0.12";
    addonId = "{1af5f0df-ce7b-4b5f-a0e1-b66675ae81f9}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/${fileId}/${pname}-${version}.xpi";
    hash = "sha256-QYvRfWeINibQ6sJQsM/Qj7FjOI5/cVqYzVcg1umNdJc=";
    meta = with lib; {
      description =
        "Auto clicks the Channel Points bonus chest for you, so you can watch streams in peace.";
      license = licenses.mit; # all rights reserved
      mozPermissions = [ ];
      platforms = platforms.all;
    };
  };
  # Get rid of Twitch's pre-roll ads (mostly). Let me browse in peace.
  ttv-lol-pro = let fileId = "4209247";
  in pkgs.buildFirefoxXpiAddon rec {
    pname = "ttv_lol_pro";
    version = "2.2.3";
    addonId = "{76ef94a4-e3d0-4c6f-961a-d38a429a332b}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/${fileId}/${pname}-${version}.xpi";
    hash = "sha256-RsdyxyFqDJ6tOW6OvPk+Lp6IWn26jfm376K4pNmvi/I=";
    meta = with lib; {
      description = "TTV LOL PRO removes most livestream ads from Twitch.";
      license = licenses.gpl3;
      mozPermissions = [
        "proxy"
        "storage"
        "webRequest"
        "webRequestBlocking"
        "https://*.ttvnw.net/*"
        "https://*.twitch.tv/*"
        "https://perfprod.com/ttvlolpro/telemetry"
      ];
    };
  };

  # This extension is amazing, check it out if you use Twitch.
  frankerfacez = pkgs.buildFirefoxXpiAddon rec {
    pname = "frankerfacez";
    version = "4.0";
    addonId = "frankerfacez@frankerfacez.com";
    url = "https://cdn.frankerfacez.com/script/${pname}-${version}-an+fx.xpi";
    hash = "sha256-U/yAra2c+RlGSaQtHfBz9XYsoDaJ67gmPJBsFrpqoE8=";
    meta = with lib; {
      description =
        "The Twitch Enhancement Suite - Get custom emotes and tons of new features you'll never want to go without.";
      license = licenses.asl20;
      mozPermissions = [
        "storage"
        "webRequest"
        "webRequestBlocking"
        "*://*.twitch.tv/*"
        "*://*.frankerfacez.com/*"
      ];
    };
  };
}
