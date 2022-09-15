{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  systemdSupport ? stdenv.isLinux,
  pkg-config,
  bash,
  dbus,
  systemd,
  xorg,
  ...
}: stdenv.mkDerivation rec {
  pname = "idlehack";
  version = "unstable-2021-12-05";

  src = fetchFromGitHub {
    owner = "loops";
    repo = pname;
    rev = "fd73c76c2d289f9eb9ad9b0695fa9e9f151be22f";
    sha256 = "sha256-vURFnGid52F1Jy5S9O3LRskzzxeyMzlhbwdEYQrUvWc=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ bash dbus xorg.libX11 ]
    ++ lib.optionals systemdSupport [ systemd ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ./idlehack $out/bin/idlehack
    install -Dm755 ./swayidle-inhibit $out/bin/swayidle-inhibit
    sed -i 's;#!/bin/bash;#!bin/sh;' $out/bin/swayidle-inhibit

    runHook postInstall
  '';

  meta = {
    description = "Monitor dbus and inhibit swayidle when Firefox or Chromium request it";
    longDescription = ''
      Listen for Firefox/Chromium dbus messages that request screensaver inhibit,
      typically because the user is watching video.  Sway doesn't currently listen
      for such messages, so here we create a daemon that listens for these messages
      and then invokes "/bin/swayidle-inhibit" which is responsible for temporarily
      disabling the screen blanking.
    '';
    inherit (src.meta) homepage;
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    maintainers = with maintainers; [ spikespaz ];
  };
}
