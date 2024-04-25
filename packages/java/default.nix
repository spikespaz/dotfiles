{ lib, pkgs, fetchurl, graalvmCEPackages
, systems ? [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ]
}:
let
  temurinSources = lib.importJSON ./temurin-sources.json;
  graalvmCeSources = lib.importJSON ./graalvm-ce-sources.json;

  mkJava = opts:
    pkgs.callPackage (import
      "${pkgs.path}/pkgs/development/compilers/temurin-bin/jdk-linux-base.nix"
      opts) { };

  mkBorkedGraalVmCe = { url, sha256, version, javaVersion }:
    (graalvmCEPackages.buildGraalvm {
      inherit version;
      javaVersion = toString javaVersion;
      src = fetchurl { inherit url sha256; };
      meta.platforms = systems;
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

  graalvmPlatform = let
    os = if pkgs.hostPlatform.isDarwin then
      "darwin"
    else if pkgs.hostPlatform.isLinux then
      "linux"
    else
      abort "GraalVM is not available for your OS";
    arch = if pkgs.hostPlatform.isAarch64 then
      "aarch64"
    else if pkgs.hostPlatform.is64bit then
      "amd64"
    else
      abort "GraalVM does not support your CPU architecture";
  in "${os}-${arch}";

in lib.makeExtensible (self: {
  temurin20-jre-bin = mkJava { sourcePerArch = temurinSources.openjdk20; };
  graalvm8-ce = mkBorkedGraalVmCe graalvmCeSources.java8.${graalvmPlatform};
  graalvm8-ce-jre = "${self.graalvm8-ce}/jre";
})
