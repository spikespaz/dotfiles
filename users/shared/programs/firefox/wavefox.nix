{ lib, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (self: {
  pname = "wavefox-userchrome";
  version = "1.6.123";
  src = fetchFromGitHub {
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v${self.version}";
    hash = "sha256-uVGNJKtT8MHo5a+GTW6DfpuRiCukC4e4UdnKmWIk3Zw=";
  };
  installPhase = ''
    mkdir $out
    cp -r $src/chrome -T $out
    cp -r $src/{README.md,LICENSE} -t $out
  '';
})
