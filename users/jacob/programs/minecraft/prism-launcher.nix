{
  pkgs,
  nixpkgs,
  ...
}: let
  # there are a few open issues but this seems simplest
  # <https://sourcegraph.com/github.com/NixOS/nixpkgs/-/blob/pkgs/development/compilers/graalvm/community-edition/mkGraal.nix>
  mkGraal = opts:
    pkgs.callPackage (import "${nixpkgs}/pkgs/development/compilers/graalvm/community-edition/mkGraal.nix" opts) {
      Foundation = null;
    };

  # TODO clean up the nixpkgs source code,
  # only run what is necessary and remove the stupidity here
  graalvm8-ce =
    (mkGraal {
      config = {
        x86_64-linux = {
          products = [
            "graalvm-ce"
            # "native-image-installable-svm"
          ];
          arch = "linux-amd64";
        };
      };
      defaultVersion = "21.3.1";
      javaVersion = "8";
      sourcesPath = ./graalvm8-ce-sources.json;
    })
    .overrideAttrs (old: {
      # why do I have to do this? the native image is disabled
      preInstall = ''
        mkdir -p $out/lib/svm/clibraries/linux-amd64
      '';

      # nixpkgs needs to be audited badly,
      # we are missing the pre- and post- hooks
      installPhase = ''
        runHook preInstall
        ${old.installPhase}
        runHook postInstall
      '';
    });

  graalvm8-ce-jre = "${graalvm8-ce}/jre";

  javaPackages = [
    # Java 8
    pkgs.temurin-jre-bin-8
    pkgs.zulu8
    graalvm8-ce-jre
    # Java 11
    pkgs.temurin-jre-bin-11
    pkgs.graalvm11-ce
    # Java 17
    pkgs.graalvm17-ce
    # Latest
    pkgs.temurin-jre-bin
    pkgs.zulu
  ];

  # wrapperScript = pkgs.writeShellScriptBin "polymc-minecraft-wrapper" ''
  #   export force_glsl_extensions_warn=true
  #   exec "$@"
  # '';
in {
  home.packages = [
    # TODO make a pull request
    # this is fixed on Prism Launcher
    # (pkgs.polymc.overrideAttrs (old: {
    #   buildInputs =
    #     old.buildInputs
    #     ++ [
    #       pkgs.libsForQt5.qt5.qtwayland
    #     ];
    # }))

    # Qt5 is supported by qt5ct, Qt6 is not
    (pkgs.prismlauncher-qt5.override {
      jdks = javaPackages;
    })

    # wrapperScript
  ];
}
