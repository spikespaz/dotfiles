# building from source is way too hard
{ stdenvNoCC, fetchzip, }:
stdenvNoCC.mkDerivation (self: {
  name = "proton-ge-custom";
  version = "GE-Proton7-49";
  src = fetchzip {
    url =
      "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${self.version}/${self.version}.tar.gz";
    sha256 = "1wwxh0yk78wprfi1h9n7jf072699vj631dl928n10d61p3r90x82";
  };
  preferLocalBuild = true;
  installPhase = ''
    mkdir -p $out/${self.version}
    cp -r * $out/${self.version}
  '';
})
