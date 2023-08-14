self: super: {
  tidal-hifi = super.tidal-hifi.overrideAttrs (old: rec {
    version = "5.6.0";
    src = self.fetchurl {
      url =
        "https://github.com/Mastermindzh/tidal-hifi/releases/download/${version}/tidal-hifi_${version}_amd64.deb";
      sha256 = "sha256-HKylyYhbMxYfRRP9irGMTtB497o75M+ryikQHMJWbtU=";
    };
    preferLocalBuild = true;
    nativeBuildInputs = old.nativeBuildInputs ++ [ self.makeWrapper ];
    postFixup = old.postFixup + ''
      wrapProgram $out/bin/tidal-hifi \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
    '';
  });
}
