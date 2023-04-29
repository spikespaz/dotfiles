{ lib, stdenv, fetchFromGitHub, }:
stdenv.mkDerivation rec {
  pname = "adi1090x-rofi-themes";
  version = "1";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "999353000ac9ba7ff98d459231751cb067874570";
    sha256 = "sha256-LsX543Pehflm/SP6bdffu1DZMrtzYKAyf6Riag/wlNw=";
  };

  replaceImportFrom = ''@import\s\+\"\(.\+\)\"'';
  replaceImportTo = ''@import \"$(dirname $file)/\1\"'';

  installPhase = ''
    runHook preInstall

    fonts_dir=$out/share/fonts/truetype/rofi
    config_dir=$out/share/rofi

    mkdir -p $fonts_dir $config_dir

    cp -rf ./fonts/* "$fonts_dir"
    cp -rf ./files/* "$config_dir"

    for file in $config_dir/**/*.rasi; do
      sed -i "s|${replaceImportFrom}|${replaceImportTo}|g" "$file"
    done

    runHook postInstall
  '';

  meta = {
    description = "adi1090x's Rofi themes";
    inherit (src) hostname;
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ spikespaz ];
  };
}
