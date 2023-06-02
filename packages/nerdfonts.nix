{ stdenvNoCC, lib, fetchFromGitHub }:
stdenvNoCC.mkDerivation rec {
  pname = "nerdfonts-symbols-only";
  version = "3.0.1";
  src = fetchFromGitHub {
    owner = "ryanoasis";
    repo = "nerd-fonts";
    rev = "v${version}";
    sha256 = "sha256-4KpwL2UkqKsyyQG/ATk+eEokaVfeUt6eXYcR2wDRqn0=";
  };
  enabledPhases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype
    cp ./patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFont{,Mono}-Regular.ttf $out/share/fonts/truetype
    runHook postInstall
  '';
}
