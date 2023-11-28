{ stdenv, fetchFromGitHub, gnumake }:
stdenv.mkDerivation (self: {
  pname = "amdctl";
  version = "0.11";
  nativeBuildInputs = [ gnumake ];
  src = fetchFromGitHub {
    owner = "kevinlekiller";
    repo = "amdctl";
    rev = "v${self.version}";
    sha256 = "sha256-2wBk/9aAD7ARMGbcVxk+CzEvUf8U4RS4ZwTCj8cHNNo=";
  };
  installPhase = ''
    runHook preInstall
    make
    install -Dm555 ./amdctl $out/bin/amdctl
    runHook postInstall
  '';
})
