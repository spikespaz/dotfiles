{
  maintainers,
  lib,
  stdenv,
  fetchurl,
  p7zip,
  acceptEula ? false,
  enableBaseFonts ? true,
  enableJapaneseFonts ? true,
  enableKoreanFonts ? true,
  enableSeaFonts ? true,
  enableThaiFonts ? true,
  enableChineseSimplifiedFonts ? true,
  enableChineseTraditionalFonts ? true,
  enableOtherFonts ? true,
}:
assert lib.assertMsg acceptEula ''
  You must override this package and accept the EULA. (ttf-ms-win11)
  <http://corefonts.sourceforge.net/eula.htm>
'';
assert lib.assertMsg (
  enableBaseFonts
  || enableJapaneseFonts
  || enableKoreanFonts
  || enableSeaFonts
  || enableThaiFonts
  || enableChineseSimplifiedFonts
  || enableChineseTraditionalFonts
  || enableOtherFonts
) ''
  You must have at least one set of fonts enabled for this package. (ttf-ms-win11)
'';
let
  inherit (import ./hashes.nix) fonts sha256Hashes;
in stdenv.mkDerivation rec {
  src = fetchurl {
    # <https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise>
    url = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/22000.318.211104-1236.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso";
    sha256 = "684bc16adbd792ef2f7810158a3f387f23bf95e1aee5f16270c5b7f56db753b6";
  };

  eula = fetchurl {
    url = "http://corefonts.sourceforge.net/eula.htm";
    sha256 = "1aqbcnl032g2hd7iy56cs022g47scb0jxxp3mm206x1yqc90vs1c";
  };

  pname = "ttf-ms-win11";
  version = "1";

  strictDeps = true;
  doCheck = true;

  nativeBuildInputs = [ p7zip ];

  enabledFonts =
    lib.optionals enableBaseFonts fonts.base
    ++ lib.optionals enableJapaneseFonts fonts.japanese
    ++ lib.optionals enableKoreanFonts fonts.korean
    ++ lib.optionals enableSeaFonts fonts.sea
    ++ lib.optionals enableThaiFonts fonts.thai
    ++ lib.optionals enableChineseSimplifiedFonts fonts.zh_cn
    ++ lib.optionals enableChineseTraditionalFonts fonts.zh_tw
    ++ lib.optionals enableOtherFonts fonts.other;

  unpackPhase = ''
    mkdir -p ./fonts

    echo 'Extracting 'install.wim'...'
    7z e "$src" sources/install.wim

    echo 'Extracting font files...'
    7z e ./install.wim \
      Windows/Fonts/'*'.{ttf,ttc} \
      -o./fonts

    echo 'Extracting license file...'
    7z e ./install.wim \
      Windows/System32/Licenses/neutral/'*'/'*'/license.rtf
  '';

  configurePhase = ''
    ${lib.toShellVar "filenames" enabledFonts}
    ${lib.toShellVar "checksums" sha256Hashes}

    echo "Preparing to install ''${#filenames[@]} fonts."
    echo "There are ''${#checksums[@]} known hashes."
  '';

  checkPhase = ''
    for filename in "''${filenames[@]}"; do
      echo "Checking '$filename'..."
      filepath="./fonts/$filename"

      if [ ! -f "$filepath" ]
      then
        echo "Could not find '$filename' in extracted files!"
        exit 11
      fi

      checksum="$(sha256sum "$filepath" | cut -d ' ' -f 1)"
      echo "'$filename': $checksum"

      if [ ! $(printf '%s\n' "''${checksums[@]}" | grep -Fx -- "$checksum") ]
      then
        echo "Checksum for '$filename' did not match!"
        exit 12
      fi
    done

    echo 'All requested files present, checksums validated.'
  '';

  installPhase = ''
    mkdir -p $out

    echo "Installing to '$out'"
    echo "$filenames"

    for filename in "''${filenames[@]}"
    do
      install -Dm644 "./fonts/$filename" "$out/share/fonts/truetype/MicrosoftFonts"
    done

    install -Dm644 ./license.rtf "$out/share/licenses/MicrosoftFonts"
    install -Dm644 '${eula}' "$out/share/licenses/MicrosoftFonts"
  '';

  meta = {
    description = "Microsoft's TrueType fonts from Windows 11";
    homepage = "https://www.microsoft.com/typography/fonts/product.aspx?PID=164";
    platforms = lib.platforms.all;
    license = lib.licenses.unfreeRedistributable;
    maintainers = with maintainers; [ spikespaz ];
  };
}
