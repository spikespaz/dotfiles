{ stdenvNoCC, fetchzip, fontFormats ? [ "ttf" "woff" "woff2" ] }:
stdenvNoCC.mkDerivation (self: {
  pname = "fork-awesome";
  version = "1.2.0";

  preferLocalBuild = true;

  src = fetchzip {
    url =
      "https://github.com/ForkAwesome/Fork-Awesome/archive/${self.version}.zip";
    sha256 = "sha256-zG6/0dWjU7/y/oDZuSEv+54Mchng64LVyV8bluskYzc=";
  };

  inherit fontFormats;

  installPhase = ''
    runHook preInstall

    for format in ''${fontFormats[@]}; do
      mkdir -p $out/share/fonts/$format
      mv ./fonts/*.$format $out/share/fonts/$format/
    done

    runHook postInstall
  '';
})
