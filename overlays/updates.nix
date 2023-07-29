self: super: {
  tidal-hifi = super.tidal-hifi.overrideAttrs (old: rec {
    version = "5.4.0";
    src = self.fetchurl {
      url =
        "https://github.com/Mastermindzh/tidal-hifi/releases/download/${version}/tidal-hifi_${version}_amd64.deb";
      sha256 = "sha256-D1gxBmqVydo5oJyNtjSdkop8v2dSGyPxQHkwBNvI51E=";
    };
    preferLocalBuild = true;
  });
}
