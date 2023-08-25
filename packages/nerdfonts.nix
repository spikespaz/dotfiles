{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation (self: {
  pname = "nerdfonts-symbols";
  version = "3.0.2";
  src = fetchzip {
    url =
      "https://github.com/ryanoasis/nerd-fonts/releases/download/v${self.version}/NerdFontsSymbolsOnly.tar.xz";
    sha256 = "sha256-clfxFE1MvBUKn3NR/3WxW08R/4HZy0qZZi+S4Pt6WvI=";
    stripRoot = false;
  };
  enabledPhases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype
    cp ./SymbolsNerdFont{,Mono}-Regular.ttf $out/share/fonts/truetype
    runHook postInstall
  '';
})
