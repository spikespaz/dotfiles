{
  maintainers,
  lib,
  stdenv,
  makeWrapper,
  bash,
  coreutils,
  gawk,
  gnugrep,
  bc,
  libnotify,
  wireplumber,
  ...
}: stdenv.mkDerivation {
  pname = "keyboard-functions";
  version = "0.0.1";

  strictDeps = true;

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ./functions.sh $out/bin/functions
    mkdir -p $out/share
    cp -r ./icons -t $out/share

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/functions \
      --set PATH \
        '${lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          bc
          libnotify
          wireplumber
        ]}' \
      --set ICONS_DIRECTORY \
        $out/share/icons/rounded-white
  '';

  meta = {
    description = ''
      Shell script to execute actions when function keys are triggered
    '';
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "functions";
    maintainers = with maintainers; [ spikespaz ];
  };
}
