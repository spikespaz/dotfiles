{
  # maintainers,
  lib,
  stdenv,
  makeWrapper,
  bash,
  coreutils,
  dbus,
  libnotify,
  evtest,
  # expected to be overridden
  disableDevices ? [],
}:
stdenv.mkDerivation {
  pname = "wayland-disable-keyboard";
  version = "0.0.1";

  strictDeps = true;

  src = ./.;

  nativeBuildInputs = [makeWrapper];

  installPhase = let
    rootScriptPath = lib.makeBinPath [bash evtest];
    userScriptPath =
      "/run/wrappers/bin:"
      + lib.makeBinPath [
        bash
        coreutils
        dbus
        libnotify
      ];
    disableDevices' = lib.concatStringsSep ":" disableDevices;
  in ''
    runHook preInstall

    install -Dm755 disable-devices.sh $out/bin/disable-input-devices
    install -Dm755 disable-devices-notify.sh $out/bin/disable-input-devices-notify

    sed -i \
      "s;toggle_script=.\+;toggle_script='$out/bin/disable-input-devices';" \
      $out/bin/disable-input-devices-notify

    wrapProgram $out/bin/disable-input-devices \
      --set PATH '${rootScriptPath}' \
      --set DISABLE_DEVICES '${disableDevices'}'

    wrapProgram $out/bin/disable-input-devices-notify \
      --set PATH '${userScriptPath}' \
      --set DEVICE_COUNT ${toString (builtins.length disableDevices)}

    runHook postInstall
  '';

  meta = {
    description = lib.mdDoc ''
      Simple utility to temporarily disable the keyboard
      (and other input devices). Requires `disableDevices` to be
      passed as an argument to the package, usually via override.
    '';
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    # maintainers = with maintainers; [spikespaz];
  };
}
