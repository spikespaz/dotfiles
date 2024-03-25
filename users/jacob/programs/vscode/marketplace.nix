{ lib, pkgs, vscode-marketplace ? pkgs.vscode-marketplace
, vscode-marketplace-release ? pkgs.vscode-marketplace-release, }:
let
  # For two attribute sets `preferred` and `fallback`, where the first depth of
  # each is a namespace and the second depth is the name of a derivation,
  # merge them together choosing derivations from `preferred` if it occurs in both.
  mergeExtensionAttrs = preferred: fallback:
    lib.recursiveUpdateUntil (path: a: b:
      let
        aIsDrv = lib.isDerivation a;
        bIsDrv = lib.isDerivation b;
      in assert lib.assertMsg (aIsDrv -> bIsDrv && bIsDrv -> aIsDrv) ''
        Found two attributes at equal depth where one is not a derivation.
        Offending attribute path: `${lib.concatStringsSep "." path}`
      '';
      aIsDrv && bIsDrv) fallback preferred;
in rec {
  releases = vscode-marketplace-release;
  latest = vscode-marketplace;
  preferReleases = mergeExtensionAttrs latest releases;
}
