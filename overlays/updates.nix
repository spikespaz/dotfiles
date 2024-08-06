pkgs: pkgs0:
let inherit (pkgs) lib;
in {
  onlyoffice-bin_latest = pkgs0.onlyoffice-bin_latest.overrideAttrs
    (self: super: {
      version = "8.0.1";
      src = pkgs.fetchurl {
        url =
          "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/v${self.version}/onlyoffice-desktopeditors_amd64.deb";
        hash = "sha256-WXjPdGwwdO13vsyVYTuoLgMedsADS8aOvZL+cwccBWQ=";
      };
    });

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
