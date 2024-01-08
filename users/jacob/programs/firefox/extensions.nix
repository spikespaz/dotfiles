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
  twitchautoclicker = let fileId = "3944212";
  in buildFirefoxXpiAddon rec {
    pname = "twitchautoclicker";
    version = "0.0.12";
    addonId = "{1af5f0df-ce7b-4b5f-a0e1-b66675ae81f9}";
    url =
      "https://addons.mozilla.org/firefox/downloads/file/${fileId}/twitchautoclicker-${version}.xpi";
    hash = "sha256-QYvRfWeINibQ6sJQsM/Qj7FjOI5/cVqYzVcg1umNdJc=";
    meta = with lib; {
      description =
        "Auto clicks the Channel Points bonus chest for you, so you can watch streams in peace.";
      license = licenses.mit; # all rights reserved
      mozPermissions = [ ];
      platforms = platforms.all;
    };
  };
}
