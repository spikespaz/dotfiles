# Overrides to keep packages building after Rust 1.80.0.
# There is a regression with type inference that primarily affects
# the `time` crate, so for packages that use it, go back one version.
# <https://github.com/NixOS/nixpkgs/issues/332957>
pkgs: pkgs0:
let
  rustVersion = "1.79.0";
  rustPlatform = pkgs.makeRustPlatform {
    cargo = pkgs.rust-bin.stable.${rustVersion}.default;
    rustc = pkgs.rust-bin.stable.${rustVersion}.default;
  };
in builtins.listToAttrs (map (name: {
  inherit name;
  value = pkgs0.${name}.override { inherit rustPlatform; };
}) [ "lapce" "deepfilternet" "rustdesk" "delta" "bandwhich" ])
