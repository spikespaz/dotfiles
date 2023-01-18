# This file contains overlays that fix issues with nixpkgs.
# TODO: When I have the time, I need to turn these into pull requests.
lib: (_: prev: {
  # Fuck you Oracle
  # <https://nadwey.eu.org/java/8/jdk-8u351/>
  oraclejdk = let
    jdk8-linux = import "${prev.path}/pkgs/development/compilers/oraclejdk/jdk-linux-base.nix" {
      productVersion = "8";
      patchVersion = "351";
      sha256.x86_64-linux = "07fw6j38gz0jwxg9qkzsdjzxcnivwq48i9b7pmy7fgk184qcl2gr";
      jceName = "jce_policy-8.zip";
      sha256JCE = "";
    };
  in
    prev.callPackage jdk8-linux {
      installjdk = true;
      pluginSupport = false;
    };

  # TODO this doesn't work
  fprintd-grosshack = prev.fprintd.overrideAttrs (old: rec {
    version = "0.3.0";
    # doCheck = false;
    src = prev.fetchFromGitLab {
      owner = "mishakmak";
      repo = "pam-fprint-grosshack";
      rev = "v${version}";
      sha256 = "sha256-obczZbf/oH4xGaVvp3y3ZyDdYhZnxlCWvL0irgEYIi0=";
    };
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
