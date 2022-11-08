{pkgs, ...}: let
  # just in case the project gets forked again
  launcherName = "PrismLauncher";
in {
  home.packages = [
    # TODO make a pull request
    # (pkgs.polymc.overrideAttrs (old: {
    #   buildInputs =
    #     old.buildInputs
    #     ++ [
    #       pkgs.libsForQt5.qt5.qtwayland
    #     ];
    # }))
    pkgs.prismlauncher
  ];

  xdg.dataFile."${launcherName}/java/graalvm-ce-java17".source = pkgs.graalvm17-ce;
  xdg.dataFile."${launcherName}/java/graalvm-ce-java11".source = pkgs.graalvm11-ce;
  # TODO I don't know why but this one polymc doesn't like
  xdg.dataFile."${launcherName}/java/graalvm-ce-java8".source = builtins.fetchTarball {
    url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.3.1/graalvm-ce-java8-linux-amd64-21.3.1.tar.gz";
    sha256 = "sha256:1n6bnvf51gld4hc7dkikmlaqcxxkspjkpck9w912pvjllpi4k3p9";
  };
  xdg.dataFile."${launcherName}/java/zulu-java8".source = pkgs.zulu8;
}
# Overriding PolyMC because of:
#
# qt.qpa.plugin: Could not find the Qt platform plugin "wayland" in ""
# This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.
# Available platform plugins are: offscreen, eglfs, linuxfb, minimal, minimalegl, vnc, xcb, vkkhrdisplay.
# zsh: IOT instruction (core dumped)  polymc

