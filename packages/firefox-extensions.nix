{ lib, buildFirefoxXpiAddon }: {
  # Clicks the stupid little green loot box for me.
  twitch-auto-clicker = let fileId = "3944212";
  in buildFirefoxXpiAddon rec {
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
  ttv-lol-pro = let fileId = "4436505";
  in buildFirefoxXpiAddon rec {
    pname = "ttv_lol_pro";
    version = "2.4.0";
    addonId = "{76ef94a4-e3d0-4c6f-961a-d38a429a332b}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/${fileId}/${pname}-${version}.xpi";
    hash = "sha256-eLQvqrhgpSfDaCKzSxblsSYYqjh+pj3rgihS0wZb8/g=";
    meta = with lib; {
      description = "TTV LOL PRO removes most livestream ads from Twitch.";
      license = licenses.gpl3;
      mozPermissions = [
        "proxy"
        "storage"
        "webRequest"
        "webRequestBlocking"
        "https://*.live-video.net/*"
        "https://*.ttvnw.net/*"
        "https://*.twitch.tv/*"
        "https://perfprod.com/ttvlolpro/telemetry"
      ];
    };
  };

  # This extension is amazing, check it out if you use Twitch.
  frankerfacez = let fileId = "4464564";
  in buildFirefoxXpiAddon rec {
    pname = "frankerfacez";
    version = "4.77.3.0";
    addonId = "frankerfacez@frankerfacez.com";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/${fileId}/${pname}-${version}.xpi";
    hash = "sha256-CEvsSSHlXgGQvyQhEt7Gs3ke7i/6UNDcLIdXNISpVLM=";
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

  pwas-for-firefox = let fileId = "4437768";
  in buildFirefoxXpiAddon rec {
    pname = "pwas_for_firefox";
    version = "2.14.1";
    addonId = "firefoxpwa@filips.si";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/${fileId}/${pname}-${version}.xpi";
    hash = "sha256-+Om6CuOnKAhNdG0RWY9oQKy72kW9wunlK3S9G5XsXRw=";
    meta = with lib; {
      description =
        "A tool to install, manage and use Progressive Web Apps (PWAs) in Mozilla Firefox";
      license = licenses.mpl20;
      mozPermissions = [
        "http://*/*"
        "https://*/*"
        "nativeMessaging"
        "notifications"
        "storage"
        "webNavigation"
        "webRequest"
        "webRequestBlocking"
      ];
    };
  };
}
