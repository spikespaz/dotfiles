pkgs: pkgs0:
let inherit (pkgs) lib;
in {
  gallery-dl = pkgs0.gallery-dl.overrideAttrs (self: super: {
    version = "1.27.2";
    src = pkgs.fetchFromGitHub {
      owner = "mikf";
      repo = "gallery-dl";
      rev = "v${self.version}";
      hash = "sha256-gb2YeBIRCH/QfF7QhkvGuCWjquvU1WmsIwxWUYGiQXA=";
    };
  });
}
