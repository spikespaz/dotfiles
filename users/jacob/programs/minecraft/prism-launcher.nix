{ nixpkgs, lib, pkgs, ... }:
let
  package = pkgs.prismlauncher-qt5;

  inherit (pkgs.callPackage ./graalvm.nix { }) graalvm8-ce-jre;
  mkJava = opts:
    pkgs.callPackage (import
      "${nixpkgs}/pkgs/development/compilers/temurin-bin/jdk-linux-base.nix"
      opts) { };
  temurinSources = lib.importJSON ./temurin-sources.json;
  temurin20-jre-bin = mkJava { sourcePerArch = temurinSources.openjdk20; };

  javaPackages = [
    # Java 8
    pkgs.temurin-jre-bin-8
    pkgs.zulu8
    graalvm8-ce-jre
    # Java 11
    pkgs.temurin-jre-bin-11
    # Java 20
    temurin20-jre-bin
    # Latest
    pkgs.temurin-jre-bin
    pkgs.zulu
    pkgs.graalvm-ce
  ];

  cmd.preLaunch = ''
    bash -c "test -f '$INST_MC_DIR/options.txt' && sed -i 's/fullscreen:true/fullscreen:false/' '$INST_MC_DIR/options.txt' || exit 0"
  '';

  cmd.wrapper = ''
    export force_glsl_extensions_warn=true
    run-game "$@"
  '';

  cmd.postExit = "";
in {
  home.packages = [
    # TODO make a pull request
    # this is fixed on Prism Launcher
    # (pkgs.polymc.overrideAttrs (self: super: {
    #   buildInputs = super.buildInputs ++ [ pkgs.libsForQt5.qt5.qtwayland ];
    # }))

    # Qt5 is supported by qt5ct, Qt6 is not
    (package.override { jdks = javaPackages; })

    # wrapperScript
  ];
}
