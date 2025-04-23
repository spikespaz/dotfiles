pkgs: pkgs0:
let inherit (pkgs) lib;
in {
  materia-kde-theme = pkgs0.materia-kde-theme.overrideAttrs (self: _: {
    version = "20220823";
    src = pkgs.fetchFromGitHub {
      owner = "PapirusDevelopmentTeam";
      repo = "materia-kde";
      rev = self.version;
      hash = "sha256-/O+/L6C9WjxhfWZ8RzIeimNU+8sjKvbDvQwNlvVOjU4=";
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
