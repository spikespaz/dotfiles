{ lib, stdenv, makeWrapper, coreutils, perl, wl-clipboard, slurp, grim, ... }:
stdenv.mkDerivation {
  pname = "prtsc";
  version = "0.0.1";

  strictDeps = true;

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ./prtsc.pl $out/bin/prtsc.pl

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper ${lib.getExe perl} $out/bin/prtsc \
      --add-flags "$out/bin/prtsc.pl" \
      --set PATH \
      "${lib.makeBinPath [ coreutils wl-clipboard slurp grim ]}"
  '';

  meta = {
    description = "Simple screenshot utility for Wayland";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ spikespaz ];
  };
}
