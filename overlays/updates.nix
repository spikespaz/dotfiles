pkgs: pkgs0:
let inherit (pkgs) lib;
in {
  materia-kde-theme = pkgs0.materia-kde-theme.overrideAttrs (self: _: {
    version = "20220823+unstable-2023-07-15";
    src = pkgs.fetchFromGitHub {
      owner = "PapirusDevelopmentTeam";
      repo = "materia-kde";
      rev = "6cc4c1867c78b62f01254f6e369ee71dce167a15";
      hash = "sha256-tZWEVq2VYIvsQyFyMp7VVU1INbO7qikpQs4mYwghAVM=";
    };
  });

  kdePackages = pkgs0.kdePackages // {
    qt6ct = pkgs0.qt6ct.overrideAttrs (self: _: {
      version = "0.10";
      src = pkgs.fetchFromGitHub {
        owner = "ilya-fedin";
        repo = "qt6ct";
        rev = self.version;
        hash = "sha256-ePY+BEpEcAq11+pUMjQ4XG358x3bXFQWwI1UAi+KmLo=";
      };
    });
  };
}
