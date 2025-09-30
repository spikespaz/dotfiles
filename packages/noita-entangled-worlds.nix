{ lib, runCommandNoCC, fetchFromGitHub, rustPlatform, pkg-config, cmake
, patchelf, openssl, libjack2, alsa-lib, libopus, wayland, libxkbcommon, libGL
}:
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
  nativeBuildInputs = [ pkg-config cmake patchelf ];
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

  postFixup = ''
    patchelf $out/bin/noita-proxy \
      --set-rpath ${lib.makeLibraryPath finalAttrs.buildInputs}
  '';

  steamworksRedist = runCommandNoCC "${finalAttrs.pname}-steamworks-redist" {
    inherit (finalAttrs) src;
  } ''
    install -Dm555 $src/redist/libsteam_api.so -t $out/lib
  '';

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
