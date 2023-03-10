final: prev: {
  # TODO this doesn't work
  fprintd-grosshack = final.fprintd.overrideAttrs (old: rec {
    version = "0.3.0";
    # doCheck = false;
    src = final.fetchFromGitLab {
      owner = "mishakmak";
      repo = "pam-fprint-grosshack";
      rev = "v${version}";
      sha256 = "sha256-obczZbf/oH4xGaVvp3y3ZyDdYhZnxlCWvL0irgEYIi0=";
    };
  });
}
