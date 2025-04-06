{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (self: {
  pname = "wavefox-userchrome";
  version = "1.8.138-unstable";
  src = fetchFromGitHub {
    owner = "QNetITQ";
    repo = "WaveFox";
    # Using this to respect `browser.tabs.tabMinWidth`.
    rev = "b8edea63e6543267ee498ec976020f991199eca6";
    hash = "sha256-wANcp1ZlZJDoFYwpfp/R63VdRvmhaBL+TgoReSuC11U=";
  };
  installPhase = ''
    mkdir $out
    cp -r $src/chrome -T $out
    cp -r $src/{README.md,LICENSE} -t $out
  '';
})
