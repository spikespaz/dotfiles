# This file contains overlays that fix issues with nixpkgs.
# TODO: When I have the time, I need to turn these into pull requests.
lib: (_: prev: {
  haruna = prev.haruna.overrideAttrs (old: rec {
    version = "0.10.2";
    src = prev.fetchFromGitLab {
      owner = "multimedia";
      repo = "haruna";
      rev = "v${version}";
      hash = "sha256-hhHWxmr2EzW9QqfV1bpJCiWOWsmGJmvxvtQcuXlMTc4=";
      domain = "invent.kde.org";
    };
  });

  # Oracle, fuck you. 🖕
  # <https://nadwey.eu.org/java/8/jdk-8u351/>
  # This override calls `jdk-linux-base.nix` with product information
  # matching a tarball that we can get from the link above.
  # In order to hide the "we can't download that for you" message
  # shown by `pkgs.requireFile` in the nixpkgs source,
  # we hijack the `requireFile` function passed to `package` below
  # and if the name matches the product information for this
  # shady tarball, substitute it with the automatic download.
  # Note that this does not take into account anything except the basic
  # default package options. If you need the JCE for example, you're on your own.
  # Read up on the nixpkgs source to understand this more:
  # <https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/compilers/oraclejdk/jdk-linux-base.nix#L80>
  oraclejdk = let
    product = {
      productVersion = "8";
      patchVersion = "351";
      sha256.x86_64-linux = "07fw6j38gz0jwxg9qkzsdjzxcnivwq48i9b7pmy7fgk184qcl2gr";
      jceName = "jce_policy-8.zip";
      sha256JCE = "";
    };
    src = prev.fetchzip {
      url = "https://nadwey.eu.org/java/8/jdk-8u351/jdk-8u351-linux-x64.tar.gz";
      sha256 = "sha256-vHqjfVqEzWHaIOeZglzAoIwxTxhmy5AbJVsyoJgSDcg=";
    };
    package = import "${prev.path}/pkgs/development/compilers/oraclejdk/jdk-linux-base.nix" product;
    platformName = builtins.getAttr prev.stdenv.hostPlatform.system {
      i686-linux = "linux-i586";
      x86_64-linux = "linux-x64";
      armv7l-linux = "linux-arm32-vfp-hflt";
      aarch64-linux = "linux-aarch64";
    };
  in
    prev.callPackage package {
      installjdk = true;
      pluginSupport = false;
      requireFile = args @ {name, ...}:
        if name == "jdk-${product.productVersion}u${product.patchVersion}-${platformName}.tar.gz"
        then src
        else prev.requireFile args;
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
