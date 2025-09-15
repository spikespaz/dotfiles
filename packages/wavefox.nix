{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (self: {
  pname = "wavefox-userchrome";
  version = "1.8.143";
  src = fetchFromGitHub {
    owner = "QNetITQ";
    repo = "WaveFox";
    rev = "v${self.version}";
    hash = "sha256-l2S12ck7Ytj6NXnRv2KYVkMyCMt7RUd3awwqNzkX65s=";
  };
  installPhase = ''
    mkdir $out
    cp -r $src/chrome -T $out
    cp -r $src/{README.md,LICENSE} -t $out
  '';
})
