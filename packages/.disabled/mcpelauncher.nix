{ lib, tree, clangStdenv, fetchurl, fetchFromGitHub, wrapQtAppsHook, symlinkJoin
, writeText, qtbase, qtwebengine, cmake, pkg-config, nlohmann_json, openssl
, curlMinimal, zlib, libzip, pngpp, libGL, xorg, libevdev, }:
let
  organization = "minecraft-linux";

  jsonCMake = writeText "json.cmake" ''
    find_package(nlohmann_json 3.7.3 REQUIRED)
  '';

  nlohmann_json' =
    (nlohmann_json.override { stdenv = clangStdenv; }).overrideAttrs
    (self: super: {
      version = "3.7.3";
      src = fetchFromGitHub {
        owner = "nlohmann";
        repo = "json";
        rev = "v${self.version}";
        hash = "sha256-PNH+swMdjrh53Ioz2D8KuERKFpKM+iBf+eHo+HvwORM=";
      };
    });

  # msa = clangStdenv.mkDerivation (self: {
  #   pname = "msa";
  #   version = "0.6.0";

  #   src = fetchFromGitHub {
  #     owner = organization;
  #     repo = "msa-manifest";
  #     rev = "v${self.version}";
  #     sha256 = "sha256-iodgCrXRAFDazz5fwgzMNhW0fsN+kt0NjnXVvl1lWUc=";
  #     fetchSubmodules = true;
  #   };

  #   postUnpack = ''
  #     cp ${jsonCMake} source/ext/json.cmake
  #   '';

  #   nativeBuildInputs = [cmake pkg-config wrapQtAppsHook];
  #   buildInputs = [qtbase qtwebengine nlohmann_json openssl curlMinimal];

  #   cmakeFlags = [
  #     "-DENABLE_MSA_QT_UI=ON"
  #     # "DMSA_UI_PATH_DEV=OFF"
  #     # "DFETCHCONTENT_SOURCE_DIR_NLOHMANN_JSON_EXT=${nlohmann-json}"
  #   ];
  # });
  mcpelauncher = clangStdenv.mkDerivation (self: {
    pname = "mcpelauncher";
    version = "0.8.0";
    src = fetchFromGitHub {
      owner = organization;
      repo = "mcpelauncher-manifest";
      rev = "v${self.version}";
      sha256 = "sha256-i3KP6qq41MjD5cnt9LWLRXcuHahtcmnIy81WyQEsp0o=";
      fetchSubmodules = true;
    };
    postUnpack = ''
      cp ${jsonCMake} source/ext/json.cmake
    '';
    nativeBuildInputs = [ cmake pkg-config ];
    buildInputs = [
      nlohmann_json'
      curlMinimal
      zlib
      pngpp
      libGL
      xorg.libX11
      libevdev
      qtbase
      qtwebengine
      wrapQtAppsHook
    ];
    # cmakeFlags = [
    #   "DUSE_OWN_CURL=ON"
    # ];
  });
  versiondb = clangStdenv.mkDerivation (self: {
    pname = "mcpelauncher-versiondb";
    version = "083802b29ae645a139077fbd496187f64dbdbc1c";
    src = fetchFromGitHub {
      owner = organization;
      repo = "mcpelauncher-versiondb";
      rev = self.version;
      sha256 = "sha256-1eEiC2dScfOTaDloZZ/46kjlv/NPonzY6THL2eyoD6k=";
    };
    installPhase = ''
      install -Dm644 \
        versions.{x86,x86_64,armeabi-v7a,arm64-v8a}.json.min \
        -t $out/share/versiondb
    '';
  });
  mcpelauncher-ui = clangStdenv.mkDerivation (self: {
    pname = "mcpelauncher-ui";
    version = "0.7.1";
    src = fetchFromGitHub {
      owner = organization;
      repo = "mcpelauncher-ui-manifest";
      rev = "v${self.version}";
      sha256 = "sha256-ga4575wYdrMUBf7Eua0Dryt0+HSZw2nvkdV1RoN4Kws=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ cmake ];
    buildInputs = [ mcpelauncher versiondb zlib libzip curlMinimal ];
    cmakeFlags = [
      # "DGAME_LAUNCHER_PATH=."
      # "DQt5QuickCompiler_FOUND=OFF"
      # "DLAUNCHER_VERSIONDB_PATH=${mcpelauncher-versiondb}/share/versiondb"
      # "DLAUNCHER_VERSION_NAME=v0.1-beta-20"
      # "DLAUNCHER_VERSION_CODE=14"
      # "DLAUNCHER_CHANGE_LOG=Ui Fixes<ul><li>    Removed Minecraft 1.16.210 from versionslist, because you can hardly craft anything in survival mode https://bugs.mojang.com/browse/MCPE-117105 and texture glitches https://bugs.mojang.com/browse/MCPE-121068</li><li>    Block launching unsupported Minecraft Versions completly</li><li>Fixed missing versionsdb glitch, now it is embedded as a fallback</li><li>Disabled devmode, start the ui with --enable-devmode to get it back</li></ul>Changes in libc-shim<ul><li>Merge pull request #8 from joserobjr/patch-1</li><li>Add a shim for malloc_usable_size (Apple included), Add shim for malloc_size for Apple</li><li>This was requested by @ChristopherHX at PR #7, Add a shim for malloc_usable_size</li><li>This is used by the release Minecraft 1.16.210.05 build, it can be passed through directly without issues.</li></ul>Changes in mcpelauncher-client<ul><li>Fix errorwindow spam (pulsaudio)..., after loosing pulseaudio connection</li><li>Merge pull request #18 from bylaws/saa</li><li>Rework core patches to be patched in via the linker, Add back CorePatches::Install to support older Minecraft versions</li><li>Rework core patches to be patched in via the linker</li><li>They are passed as an argument when loading the Minecraft library.</li></ul>Changes in mcpelauncher-core<ul><li>Add default parameter to loadMinecraftLib</li><li>Merge pull request #6 from bylaws/saa</li><li>Transition to dlext hooks for mouse visibility callbacks, Don't require mouse pointer hooks</li><li>Transition to dlext hooks for mouse visibility callbacks</li><li>1.16.210 removed the vtable symbols that were previously used for this, so use the linker extension as a workaround with callbacks being passed, in by the client.</li></ul>Changes in mcpelauncher-errorwindow<ul><li>wait for the errorwindow process</li><li>create a waiting thread to cleanup the child errorwindow process</li></ul>Changes in mcpelauncher-webview<ul><li>Merge pull request #1 from ChristopherHX/patch-1</li><li>Fix macro to be 5.12, not 5.18</li></ul>"
      # "DLAUNCHER_VERSIONDB_URL=https://raw.githubusercontent.com/minecraft-linux/mcpelauncher-versiondb/v0.1-beta-20/"
    ];
  });
in mcpelauncher-ui
# symlinkJoin {
#   name = "mcpelauncher";
#   paths = [
#     # msa
#     mcpelauncher
#     mcpelauncher-ui
#   ];
# }

