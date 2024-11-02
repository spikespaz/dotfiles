{ lib, rustPlatform }:
let
  manifest = lib.importTOML ./Cargo.toml;
  package = rustPlatform.buildRustPackage {
    pname = manifest.package.name;
    version = manifest.package.version;
    src = ./.;
    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "hyprland-0.4.0-beta.1" =
          "sha256-wTFXIXFKtZH8evPAu6AbN42banEkgH1CilaHo9fHKos=";
      };
    };
    meta.mainProgram = manifest.package.name;
  };
in lib.getExe package
