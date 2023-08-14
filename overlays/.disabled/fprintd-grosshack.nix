pkgs: pkgs0: {
  # TODO this doesn't work
  fprintd-grosshack = pkgs.fprintd.overrideAttrs (self: super: {
    version = "0.3.0";
    # doCheck = false;
    src = pkgs.fetchFromGitLab {
      owner = "mishakmak";
      repo = "pam-fprint-grosshack";
      rev = "v${self.version}";
      sha256 = "sha256-obczZbf/oH4xGaVvp3y3ZyDdYhZnxlCWvL0irgEYIi0=";
    };
  });
}
