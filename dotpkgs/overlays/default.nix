# This file contains overlays that fix issues with nixpkgs.
# TODO: When I have the time, I need to turn these into pull requests.
lib: (_: prev: {
  corectrl = prev.corectrl.overrideAttrs (old: rec {
    version = "1.3.1";
    src = prev.fetchFromGitLab {
      owner = old.pname;
      repo = old.pname;
      rev = "v${version}";
      sha256 = "sha256-mVMyXpNhwljxsAvrKeHPxUSfdF/mfxG157T13Kb8PnE=";
    };
  });

  lxqt = prev.lxqt.overrideScope' (_: prev: {
    lxqt-policykit = prev.lxqt-policykit.overrideAttrs (old: {
      meta = old.meta // {mainProgram = "lxqt-policykit-agent";};
    });
  });

  obs-studio-plugins = (
    with prev.obs-studio-plugins;
      prev.obs-studio-plugins
      // {
        # # <https://github.com/exeldro/obs-move-transition>
        # obs-move-transition = obs-move-transition.overrideAttrs (old: rec {
        #   version = "2.6.3";
        #   src = prev.fetchFromGitHub {
        #     owner = "exeldro";
        #     repo = old.pname;
        #     rev = version;
        #     sha256 = "sha256-jFN1JAaLebLqUVz/tM3i9LE4O+ih21SN8Ya+FuY5gsE=";
        #   };
        #   patches = [
        #     # ./obs-move-transition.CMakeLists.txt.patch
        #   ];
        # });
      }
  );

  # lapce = (prev.lapce.overrideAttrs (old: rec {
  #   version = "0.2.0";
  #   src = prev.fetchFromGitHub {
  #     owner = "lapce";
  #     repo = "lapce";
  #     rev = "v${version}";
  #     sha256 = "sha256-cCcI5V6CMLkJM0miLv/o7LAJedrgb+z2CtWmF5/dmvY=";
  #   };
  #   # cannot set cargoSha256 because the output is transformed before
  #   # it is overrideable, this is the way since
  #   # rustPlatform.fetchCargoTarball is lib.mkOverrideable
  #   cargoDeps = old.cargoDeps.overrideAttrs (_: {
  #     inherit src;
  #     name = "${old.pname}-${version}-vendor.tar.gz";
  #     outputHash = "sha256-H8vPBXJ0tom07wjzi18oIYNUhZXraD74DF7+xn8hfrQ=";
  #   });
  # }));
})
