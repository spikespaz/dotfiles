{ lib, pkgs, fetchurl, callPackage, graalvmCEPackages }:
let
  mkJava = opts:
    pkgs.callPackage (import
      "${pkgs.path}/pkgs/development/compilers/temurin-bin/jdk-linux-base.nix"
      opts) { };

  temurinSources = lib.importJSON ./temurin-sources.json;

  temurin20-jre-bin = mkJava { sourcePerArch = temurinSources.openjdk20; };

  graalvm8-ce = (graalvmCEPackages.buildGraalvm {
    version = "21.3.1";
    javaVersion = "8";
    src = fetchurl {
      url =
        "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.1/graalvm-ce-java8-linux-amd64-21.3.1.tar.gz";
      sha256 = "sha256-uey9VC3h7Qo9pGpinyJmqIIDJpj1/LxU2JI3K5GJsO0=";
    };
    meta.platforms = [ "x86_64-linux" ];
  }).overrideAttrs (self: super: {
    doInstallCheck = false;
    # Make sure that `native-image` exists so that `wrapProgram`
    # has something to do.
    preInstall = ''
      touch $out/bin/native-image
      chmod +x $out/bin/native-image
    '' + (super.preInstall or "");
    # Remove the `native-image` wrapper and the original empty file.
    postFixup = (super.postFixup or "") + ''
      rm $out/bin/native-image*
    '';
  });
in {
  inherit temurin20-jre-bin graalvm8-ce;
  graalvm8-ce-jre = "${graalvm8-ce}/jre";
}
