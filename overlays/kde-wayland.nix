# The proper solution here is to add `pkgs.makeOverrideable` around
# <https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/kde/lib/mk-kde-derivation.nix>
pkgs: pkgs0:
let inherit (pkgs) lib;
in {
  kdePackages = pkgs0.kdePackages.overrideScope (kdePackages: kdePackages0:
    lib.mapAttrs (_: package:
      package.overrideAttrs (_self: super: {
        buildInputs = super.buildInputs
          ++ [ kdePackages.qtwayland kdePackages.qtsvg ];
      })) {
        inherit (kdePackages0)
        # packages from Plasma
          dolphin ffmpegthumbs kimageformats kfind ark kcolorchooser kate kdf
          kompare okular print-manager skanlite
          # packages from qt6Packages
          qt6ct;
      });
}
