{
  lib,
  stdenv,
  fetchFromGitHub,
  pack ? 2,
  theme ? "green_blocks",
  ...
}: stdenv.mkDerivation {
  pname = "adi1090x-plymouth-themes";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "plymouth-themes";
    rev = "bf2f570bee8e84c5c20caac353cbe1d811a4745f";
    sha256 = "sha256-VNGvA8ujwjpC2rTVZKrXni2GjfiZk7AgAn4ZB4Baj2k=";
  };

  configurePhase = ''
    mkdir -p $out/share/plymouth/themes
  '';

  installPhase = ''
    runHook preInstall
    cp -r ./pack_${toString pack}/${theme} $out/share/plymouth/themes
    sed -i 's;/usr/share;${placeholder "out"}/share;g' \
      $out/share/plymouth/themes/${theme}/${theme}.plymouth
    runHook postInstall
  '';

  meta = with lib; {
    description = "A collection of plymouth themes ported from Android.";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with import ../maintainers.nix; [ spikespaz ];
  };
}
