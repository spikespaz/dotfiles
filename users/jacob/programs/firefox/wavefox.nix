{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (self: {
  pname = "wavefox-userchrome";
  version = "1.6.128";
  src = fetchFromGitHub {
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v${self.version}";
    hash = "sha256-HwofuoPoPZ+uuD9PVeHvxngRcBEAsSDccz1jWZWHFvI=";
  };
  installPhase = ''
    mkdir $out
    cp -r $src/chrome -T $out
    cp -r $src/{README.md,LICENSE} -t $out
  '';
})
