{
  pkgs,
  fetchurl,
  callPackage,
}: let
  buildGraalvm = callPackage "${pkgs.path}/pkgs/development/compilers/graalvm/community-edition/buildGraalvm.nix";

  graalvm8-ce =
    (buildGraalvm {
      version = "21.3.1";
      javaVersion = "8";
      src = fetchurl {
        url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.1/graalvm-ce-java8-linux-amd64-21.3.1.tar.gz";
        sha256 = "sha256-uey9VC3h7Qo9pGpinyJmqIIDJpj1/LxU2JI3K5GJsO0=";
      };
      meta.platforms = ["x86_64-linux"];
    })
    .overrideAttrs (_: {
      doInstallCheck = false;
    });
in {
  inherit graalvm8-ce;
  graalvm8-ce-jre = "${graalvm8-ce}/jre";
}
