_: prev: {
  # Oracle, fuck you. 🖕
  #
  # <https://nadwey.eu.org/java/8/>
  # <https://gist.github.com/wavezhang/ba8425f24a968ec9b2a8619d7c2d86a6>
  #
  # This override calls `jdk-linux-base.nix` with product information
  # matching a tarball that we can get from the link above.
  #
  # In order to hide the "we can't download that for you" message
  # shown by `pkgs.requireFile` in the nixpkgs source,
  # we hijack the `requireFile` function passed to `package` below,
  # and if the name matches the product information for this
  # shady tarball, substitute it with the automatic download.
  #
  # Note that this does not take into account anything except the basic
  # default package options. If you need the JCE for example, you're on your own.
  #
  # Read up on the nixpkgs source to understand this more:
  # <https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/compilers/oraclejdk/jdk-linux-base.nix#L80>
  oraclejdk = let
    product = {
      productVersion = "8";
      patchVersion = "361";
      # for <cfdownload.adobe.com>
      sha256.x86_64-linux = "sha256-JYWpJLuNLDFdj+RL+lNPYV94knlliWPTD/4Un9dB2W4=";
      # for <nadwey.eu.org>
      # sha256.x86_64-linux = "sha256-YeP0CZqZp3pweFOAizps+ofSuCsZt8dtzGxdPu37O50=";
      jceName = null;
      sha256JCE = null;
    };
    version = "${product.productVersion}u${product.patchVersion}";
    tarballName = "jdk-${version}-${platformName}.tar.gz";
    src = prev.fetchzip {
      url = "https://cfdownload.adobe.com/pub/adobe/coldfusion/java/java${product.productVersion}/java${version}/jdk/${tarballName}";
      # url = "https://nadwey.eu.org/java/${product.productVersion}/jdk-${version}/${tarballName}";
      sha256 = product.sha256.${prev.system};
    };
    package = import "${prev.path}/pkgs/development/compilers/oraclejdk/jdk-linux-base.nix" product;
    platformName = builtins.getAttr prev.system {
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
        if name == tarballName
        then src
        else prev.requireFile args;
    };
}
