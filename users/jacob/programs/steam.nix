{ pkgs, ... }:
let
  fetchProtonGE = version: hash:
    let name = "GE-Proton${version}";
    in pkgs.fetchzip {
      inherit name hash;
      url =
        "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${name}/${name}.tar.gz";
    };

  protonDists = [
    (fetchProtonGE "7-55" "sha256-6CL+9X4HBNoB/yUMIjA933XlSjE6eJC86RmwiJD6+Ws=")
    (fetchProtonGE "8-25" "sha256-IoClZ6hl2lsz9OGfFgnz7vEAGlSY2+1K2lDEEsJQOfU=")
  ];
in {
  imports = map (proton: {
    xdg.dataFile."Steam/compatibilitytools.d/${proton.name}" = {
      recursive = true;
      source = proton.outPath;
    };
  }) protonDists;
}
