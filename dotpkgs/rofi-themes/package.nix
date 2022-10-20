{
  lib,
  maintainers,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  bash,
  coreutils,
  fontconfig,
}:
stdenv.mkDerivation rec {
  pname = "adi1090x-rofi-themes";
  version = "1";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "999353000ac9ba7ff98d459231751cb067874570";
    sha256 = "sha256-LsX543Pehflm/SP6bdffu1DZMrtzYKAyf6Riag/wlNw=";
  };

  nativeBuildInputs = [makeWrapper];

  configurePhase = ''
    sed -i 's|#!/usr/bin/env bash||' ./setup.sh
    sed -i 's|FONT_DIR=".\+"|FONT_DIR="$out/share/fonts/truetype/rofi"|' ./setup.sh
    sed -i 's|ROFI_DIR=".\+"|ROFI_DIR="$out/share/rofi"|' ./setup.sh

    wrapProgram ./setup.sh \
      --set PATH \
        ${lib.makeBinPath [coreutils fontconfig]}
  '';

  installPhase = ''
    runHook preInstall

    ${lib.getExe bash} ./setup.sh

    runHook postInstall
  '';

  meta = {
    description = "adi1090x's Rofi themes";
    inherit (src) hostname;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with maintainers; [spikespaz];
  };
}
