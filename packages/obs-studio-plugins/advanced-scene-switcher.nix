{ lib, stdenv, fetchFromGitHub, wrapQtAppsHook, cmake, pkg-config, obs-studio
, qtbase, xorg, procps, curlMinimal, asio, websocketpp, opencv
, withOpenCV ? true, }:
stdenv.mkDerivation rec {
  pname = "advanced-scene-switcher";
  version = "1.20.4";

  src = fetchFromGitHub {
    owner = "WarmUpTill";
    repo = "SceneSwitcher";
    rev = version;
    sha256 = "sha256-xGPTrqJZcKLK1fV+FbgWdVFdwyI/DC5F2QzUy8YbUHs=";
  };

  nativeBuildInputs = [ wrapQtAppsHook cmake ];
  buildInputs =
    [ obs-studio qtbase procps curlMinimal asio websocketpp xorg.libXScrnSaver ]
    ++ lib.optional withOpenCV opencv;

  postInstall = ''
    mkdir -p $out/{lib/obs-plugins,share/obs/obs-plugins}
    mv $out/obs-plugins/*/* -t $out/lib/obs-plugins
    mv $out/data/obs-plugins/* -t $out/share/obs/obs-plugins
    rm -rf $out/{obs-plugins,data}
  '';
}
