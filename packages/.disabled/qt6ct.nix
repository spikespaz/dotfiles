{ stdenv, lib, fetchFromGitHub, wrapQtAppsHook, qtbase, qtsvg, qttools, qmake
, qtwayland, }:
stdenv.mkDerivation rec {
  pname = "qt6ct";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "trialuser02";
    repo = "qt6ct";
    rev = version;
    sha256 = "sha256-7WuHdb7gmdC/YqrPDT7OYbD6BEm++EcIkmORW7cSPDE=";
  };

  nativeBuildInputs = [ qmake qttools qtwayland wrapQtAppsHook ];

  buildInputs = [ qtbase qtsvg ];

  qmakeFlags = [
    "LRELEASE_EXECUTABLE=${lib.getDev qttools}/bin/lrelease"
    "PLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];

  # meta = with lib; {
  #   description = "Qt5 Configuration Tool";
  #   homepage = "https://www.opendesktop.org/content/show.php?content=168066";
  #   platforms = platforms.linux;
  #   license = licenses.bsd2;
  #   maintainers = with maintainers; [ralith];
  # };
}
