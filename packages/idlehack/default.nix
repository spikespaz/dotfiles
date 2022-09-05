{
  lib,
  stdenv,
  fetchFromGitHub,
  systemdSupport ? stdenv.isLinux,
  pkg-config,
  bash,
  dbus,
  systemd,
  libX11,
  ...
}: stdenv.mkDerivation rec {
  pname = "idlehack";
  version = "unstable-2021-12-05";

  src = fetchFromGitHub {
    owner = "loops";
    repo = "idlehack";
    rev = "298336d4609b328d71a1b460d4c241fd344be79d";
    sha256 = "sha256-ZG52/jwtqxUh+R/+hcmqNEVGAtaZbDg3I6xIokMS3+A=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ bash dbus libX11 ] ++ lib.optionals systemdSupport [ systemd ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ./idlehack $out/bin/idlehack
    install -Dm755 ./swayidle-inhibit $out/bin/swayidle-inhibit
    sed -i 's;#!/bin/bash;#!bin/sh;' $out/bin/swayidle-inhibit
    runHook postInstall
  '';

  meta = with lib; {
    description = "Monitor dbus and inhibit swayidle when Firefox or Chromium request it";
    longDescription = ''
      Listen for Firefox/Chromium dbus messages that request screensaver inhibit,
      typically because the user is watching video.  Sway doesn't currently listen
      for such messages, so here we create a daemon that listens for these messages
      and then invokes "/bin/swayidle-inhibit" which is responsible for temporarily
      disabling the screen blanking.
    '';
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with import ../maintainers.nix; [ spikespaz ];
  };
}
