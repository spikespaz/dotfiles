{
  pkgs,
  nixpkgs,
  ...
}: let
  # maybe this will change in the future?
  dataDir = "PolyMC";
  # graalvm for java 8 is not in nixpkgs,
  # there are a few open issues but this seems simplest
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
    (pkgs.prismlauncher.override {enableLTO = true;})
  ];

  xdg.dataFile."${dataDir}/java/graalvm-ce-java17".source = pkgs.graalvm17-ce;
  xdg.dataFile."${dataDir}/java/graalvm-ce-java11".source = pkgs.graalvm11-ce;
  xdg.dataFile."${dataDir}/java/graalvm-ce-java8".source = graalvm8-ce;
  xdg.dataFile."${dataDir}/java/zulu-java8".source = pkgs.zulu8;
}
# Overriding PolyMC because of:
#
# qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""
# This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.
# Available platform plugins are: offscreen, eglfs, linuxfb, minimal, minimalegl, vnc, xcb, vkkhrdisplay.
# zsh: IOT instruction (core dumped)  polymc

