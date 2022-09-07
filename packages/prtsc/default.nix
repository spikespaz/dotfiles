{
  lib,
  stdenv,
  makeWrapper,
  perl,
  wl-clipboard,
  slurp,
  grim,
  ...
}: stdenv.mkDerivation {
  pname = "prtsc";
  version = "0.0.1";

  src = ./.;

  strictDeps = true;
  # buildInputs = [ perl ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ./prtsc.pl $out/bin/prtsc
    wrapProgram $out/bin/prtsc \
      --set PATH \
      "${lib.makeBinPath ([
        perl
        wl-clipboard
        slurp
        grim
      ])}"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple screenshot utility for Wayland";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with import ../maintainers.nix; [ spikespaz ];
  };
}
