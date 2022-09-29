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
  scriptOptions ? {},
  ...
}: let
  scriptOptions' = (
    lib.recursiveUpdate
      {
        timeout = 700;
        urgency = "low";
        mainTextSize = "x-large";
        iconsDirectory = "$out/share/icons/rounded-white";
        outputTitle = "Default Audio Output";
        inputTitle = "Default Audio Input";
        outputDevice = "@DEFAULT_AUDIO_SINK@";
        inputDevice = "@DEFAULT_AUDIO_SOURCE@";
        icons = {
          outputDisable = "volume_off_white_36dp.svg";
          outputEnable = "volume_up_white_36dp.svg";
          outputIncrease = "volume_up_white_36dp.svg";
          outputDecrease = "volume_down_white_36dp.svg";
          inputDisable = "mic_off_white_36dp.svg";
          inputEnable = "mic_white_36dp.svg";
        };
      }
      scriptOptions
    );
  in stdenv.mkDerivation {
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
      --set TIMEOUT \
        '${toString scriptOptions'.timeout}' \
      --set URGENCY \
        '${scriptOptions'.urgency}' \
      --set MAIN_TEXT_SIZE \
        '${scriptOptions'.mainTextSize}' \
      --set ICONS_DIRECTORY \
        "${scriptOptions'.iconsDirectory}" \
      --set OUTPUT_TITLE \
        '${scriptOptions'.outputTitle}' \
      --set INPUT_TITLE \
        '${scriptOptions'.inputTitle}' \
      --set OUTPUT_DEVICE \
        '${scriptOptions'.outputDevice}' \
      --set INPUT_DEVICE \
        '${scriptOptions'.inputDevice}' \
      --set OUTPUT_DISABLE_ICON \
        '${scriptOptions'.icons.outputDisable}' \
      --set OUTPUT_ENABLE_ICON \
        '${scriptOptions'.icons.outputEnable}' \
      --set OUTPUT_INCREASE_ICON \
        '${scriptOptions'.icons.outputIncrease}' \
      --set OUTPUT_DECREASE_ICON \
        '${scriptOptions'.icons.outputDecrease}' \
      --set INPUT_DISABLE_ICON \
        '${scriptOptions'.icons.inputDisable}' \
      --set INPUT_ENABLE_ICON \
        '${scriptOptions'.icons.inputEnable}' \
      --set PATH \
        '${lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          bc
          libnotify
          wireplumber
        ]}'
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
