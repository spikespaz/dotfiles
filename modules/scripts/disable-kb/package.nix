{
  maintainers,
  lib,
  stdenv,
  makeWrapper,
  coreutils,
  evtest,
  libnotify,
}:
stdenv.mkDerivation {
  pname = "wayland-disable-keyboard";
  version = "0.0.1";

  strictDeps = true;

  src = ./.;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    install -Dm755 ./disable_kb.sh $out/bin/wayland-disable-keyboard

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/wayland-disable-keyboard \
      --set PATH \
        "${lib.makeBinPath [coreutils evtest libnotify]}" \
  '';

  meta = {
    description = "Simple screenshot utility for Wayland";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with maintainers; [spikespaz];
  };
}
