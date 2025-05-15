pkgs: pkgs0:
let
  inherit (pkgs) lib;

  versions = import ./versions.nix;
in {
  graalvmPackages = pkgs0.graalvmPackages // lib.mapAttrs' (version: hashes: {
    name = "graalvm-ce-${version}";
    value = pkgs.graalvmPackages.buildGraalvm {
      useMusl = false;
      src = pkgs.fetchurl hashes.hashes.${pkgs.stdenv.hostPlatform.system};
      version = hashes.version;
      meta.platforms = builtins.attrNames hashes.hashes;
    };
  }) versions;
}
