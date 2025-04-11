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
}
