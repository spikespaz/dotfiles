{ lib, runCommandNoCC, fetchFromGitHub, rustPlatform, copyDesktopItems
, makeDesktopItem, pkg-config, cmake, patchelf, imagemagick, openssl, libjack2
, alsa-lib, libopus, wayland, libxkbcommon, libGL }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "noita-entangled-worlds-proxy";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "intquant";
    repo = "noita_entangled_worlds";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DAGLpGo8K6qSfxMwTELSU9HLHRX2lp5qbmmq/tL08JM=";
  };
  sourceRoot = "${finalAttrs.src.name}/noita-proxy";

  cargoHash = "sha256-VIOr/3inwP79756UD6JIImk7rOuiHK1QiZBoqW5cSTo=";

  strictDeps = true;
  nativeBuildInputs =
    [ copyDesktopItems pkg-config cmake patchelf imagemagick ];
  buildInputs = [
    openssl
    libjack2
    alsa-lib
    libopus
    wayland
    libxkbcommon
    libGL
    finalAttrs.steamworksRedist
  ];

  env = {
    OPENSSL_DIR = "${lib.getDev openssl}";
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_NO_VENDOR = 1;
  };

  checkFlags = [
    # Disable networked tests
    "--skip bookkeeping::releases::test::release_assets"
  ];

  # TODO: Research which sizes are most important. These are what I found on my system.
  postInstall = ''
    for size in 16 20 22 24 32 48 64 96 128 144 180 192 256 512 1024; do
      icon_dir=$out/share/icons/hicolor/''${size}x''${size}/apps
      mkdir -p $icon_dir
      magick assets/icon.png \
        -strip -filter Point -resize ''${size}x''${size} \
        $icon_dir/noita-proxy.png
    done
  '';

  postFixup = ''
    patchelf $out/bin/noita-proxy \
      --set-rpath ${lib.makeLibraryPath finalAttrs.buildInputs}
  '';

  steamworksRedist = runCommandNoCC "${finalAttrs.pname}-steamworks-redist" {
    inherit (finalAttrs) src;
  } ''
    install -Dm555 $src/redist/libsteam_api.so -t $out/lib
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "noita-proxy";
      desktopName = "Noita Entangled Worlds";
      comment = finalAttrs.meta.description;
      exec = "noita-proxy";
      icon = "noita-proxy";
      categories = [ "Game" "Utility" ];
      keywords = [ "noita" "proxy" "server" "steam" "game" ];
      terminal = false;
      singleMainWindow = true;
    })
  ];

  meta = {
    description = "Noita Entangled Worlds proxy application.";
    homepage = "https://github.com/IntQuant/noita_entangled_worlds/releases";
    changelog =
      "https://github.com/IntQuant/noita_entangled_worlds/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit asl20 ];
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ spikespaz ];
    mainProgram = "noita-proxy";
  };
})
