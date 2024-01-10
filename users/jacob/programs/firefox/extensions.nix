args@{ lib, stdenv, fetchurl }:
let
  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? args.stdenv
    , fetchurl ? args.fetchurl, pname, version, addonId, url, hash, meta, ... }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url hash; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });
in {
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
  ttv-lol-pro = let fileId = "4209247";
  in buildFirefoxXpiAddon rec {
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
}
