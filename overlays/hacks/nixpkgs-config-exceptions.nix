# This overlay attempts to replace packages which take a very long time to build with
# `nixpkgs` using custom platform settings.
pkgs: pkgs0:
let
  # Using `pkgs0` to avoid infinite recursion, usually `pkgs` should be used.
  inherit (pkgs0) lib;

  # Attempt to construct a `pkgs` instance which matches the current fix-point `pkgs`,
  # without extra customizations to `stdenv` (or any overlays).
  # The arguments used for the new `localSystem` and `crossSystem` are not exactly correct,
  # the code below is just an approximation achieved by reading `pkgs/stdenv/cross/default.nix`.
  # It would be non-trivial to preserve the semantic intent of the original
  # `localSystem` and `crossSystem` which produced the original `pkgs` point.
  # I could surgically construct a new set of arguments for the new Nixpkgs import,
  # but I would rather not.
  unoptimizedPkgs = import pkgs.path {
    localSystem.system = pkgs.stdenvNoCC.buildPlatform.system;
    crossSystem.system = pkgs.stdenvNoCC.targetPlatform.system;
  };

  names = [ "electron" "electron_35" "electron_34" "electron_33" ];
in (lib.getAttrs names unoptimizedPkgs) // {
  # This will interfere with other overlays. A more surgical approach is necessary if desire is otherwise.

  qt6Packages = pkgs0.qt6Packages.overrideScope
    (_: _: { qtwebengine = unoptimizedPkgs.qt6Packages.qtwebengine; });

  kdePackages = pkgs0.kdePackages.overrideScope
    (_: _: { qtwebengine = unoptimizedPkgs.kdePackages.qtwebengine; });

  libsForQt5 = pkgs0.libsForQt5.overrideScope
    (_: _: { qtwebengine = unoptimizedPkgs.libsForQt5.qtwebengine; });
}
