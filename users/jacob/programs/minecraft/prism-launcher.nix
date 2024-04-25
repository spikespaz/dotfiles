{ nixpkgs, lib, pkgs, ... }:
let
  package = pkgs.prismlauncher-qt5;

  javaPackages = with pkgs; [
    # Java 8
    temurin-jre-bin-8
    zulu8
    graalvm8-ce-jre
    # Java 11
    temurin-jre-bin-11
    # Java 20
    temurin20-jre-bin
    # Latest
    temurin-jre-bin
    zulu
    graalvm-ce
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
