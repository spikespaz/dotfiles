{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (self: {
  pname = "wavefox-userchrome";
  version = "1.6.129";
  src = fetchFromGitHub {
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v${self.version}";
    hash = "sha256-RMv33HeAOt+ysjEEjLosVn3zheaGiLE5YPKv+QPN8KI=";
  };
  installPhase = ''
    mkdir $out
    cp -r $src/chrome -T $out
    cp -r $src/{README.md,LICENSE} -t $out
  '';
})
