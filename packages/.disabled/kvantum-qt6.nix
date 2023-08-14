{ lib, stdenv, fetchFromGitHub, cmake, libsForQt5, qt6, tree, }:
stdenv.mkDerivation (self: {
  pname = "qtstyleplugin-kvantum-qt6";
  version = "1.0.9";

  src = (fetchFromGitHub {
    owner = "tsujan";
    repo = "Kvantum";
    rev = "V${self.version}";
    sha256 = "sha256-5/cScJpi5Z5Z/SjizKfMTGytuEo2uUT6QtpMnn7JhKc=";
  }).outPath + "/Kvantum";

  nativeBuildInputs = [ cmake qt6.qttools ];

  buildInputs = [ qt6.qtbase qt6.qtsvg ];

  dontWrapQtApps = true;

  cmakeFlags = [
    # adding qt5 deps would result in an error (mismatched qt deps)
    "-DCMAKE_PREFIX_PATH=${
      lib.concatStringsSep ":" [
        libsForQt5.qtx11extras
        libsForQt5.kwindowsystem
      ]
    }"
    "-DENABLE_QT5=OFF"
  ];

  installPhase = ''
    ${lib.getExe tree}

    install -Dm555 ./style/libkvantum.so \
      -t $out/$qtPluginPrefix
  '';
})
